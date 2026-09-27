/// <reference path="../declarations.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8"
import { GoogleAuth } from "npm:google-auth-library@9.6.0"

serve(async (req: Request) => {
  // 1. Handle CORS Preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    })
  }

  try {
    // 2. Validate webhook auth token
    const authHeader = req.headers.get('Authorization')
    if (!authHeader || authHeader !== 'Bearer supabase-webhook-secret-token-3omar') {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 3. Parse request body
    const body = await req.json()
    const { transaction_id, customer_id, amount, description } = body

    if (!transaction_id || !customer_id || amount === undefined) {
      return new Response(JSON.stringify({ error: 'Missing required parameters' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 4. Initialize Supabase Client with service_role to bypass RLS
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 5. Fetch Customer details & Market name
    const { data: customer, error: customerError } = await supabaseClient
      .from('customers')
      .select('name, user_id')
      .eq('id', customer_id)
      .single()

    if (customerError || !customer) {
      throw new Error(`Customer not found: ${customerError?.message}`)
    }

    const { data: profile, error: profileError } = await supabaseClient
      .from('profiles')
      .select('market_name')
      .eq('id', customer.user_id)
      .single()

    const marketName = profile?.market_name || 'SAMI MARKET'

    // 6. Fetch all active FCM tokens for this customer
    const { data: devices, error: devicesError } = await supabaseClient
      .from('customer_devices')
      .select('id, fcm_token')
      .eq('customer_id', customer_id)
      .eq('is_active', true)

    if (devicesError) {
      throw new Error(`Error fetching devices: ${devicesError.message}`)
    }

    if (!devices || devices.length === 0) {
      return new Response(JSON.stringify({ success: true, message: 'No registered devices for this customer' }), {
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 7. Initialize Google Auth with Firebase Service Account Key
    const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
    if (!serviceAccountStr) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT environment variable is not set')
    }

    const serviceAccount = JSON.parse(serviceAccountStr)
    const projectId = serviceAccount.project_id

    const auth = new GoogleAuth({
      credentials: {
        client_email: serviceAccount.client_email,
        private_key: serviceAccount.private_key,
      },
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })

    const authClient = await auth.getClient()
    const tokenResponse = await authClient.getAccessToken()
    const accessToken = tokenResponse.token

    if (!accessToken) {
      throw new Error('Failed to generate OAuth2 Access Token for FCM')
    }

    // 8. Construct FCM Message content
    const title = "💰 دين جديد"
    const messageBody = `تم تسجيل دين جديد بقيمة ${amount}₺ لدى ${marketName}.`

    const sendPromises = devices.map(async (device: any) => {
      const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`
      const payload = {
        message: {
          token: device.fcm_token,
          notification: {
            title: title,
            body: messageBody,
          },
          data: {
            transaction_id: String(transaction_id),
            customer_id: String(customer_id),
            type: "new_debt",
          },
          android: {
            priority: "HIGH",
            notification: {
              channel_id: "sami_market_alerts",
              sound: "default",
              default_sound: true,
              default_vibrate_timings: true,
            }
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              }
            }
          }
        }
      }

      try {
        const response = await fetch(fcmUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${accessToken}`,
          },
          body: JSON.stringify(payload)
        })

        if (!response.ok) {
          const errData = await response.json()
          console.error(`FCM send error for device ${device.id}:`, errData)

          // Delete token if unregistered or invalid (FCM HTTP status 400 or 404 with specific codes)
          const errorCode = errData.error?.status
          const errorMessage = errData.error?.message
          if (errorCode === 'UNREGISTERED' || errorCode === 'INVALID_ARGUMENT' || response.status === 404 || response.status === 410) {
            console.log(`Removing invalid token for device ID: ${device.id}`)
            await supabaseClient
              .from('customer_devices')
              .delete()
              .eq('id', device.id)
          }
        }
      } catch (err) {
        console.error(`Network error sending to device ${device.id}:`, err)
      }
    })

    await Promise.all(sendPromises)

    return new Response(JSON.stringify({ success: true, message: 'Notifications sent' }), {
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (err) {
    console.error('Edge Function Error:', err)
    return new Response(JSON.stringify({ error: err instanceof Error ? err.message : 'Internal Server Error' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
