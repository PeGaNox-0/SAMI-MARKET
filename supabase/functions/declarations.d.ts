declare module "https://deno.land/std@0.168.0/http/server.ts" {
  export function serve(handler: (req: Request) => Response | Promise<Response>): void;
}

declare module "https://esm.sh/@supabase/supabase-js@2.39.8" {
  export function createClient(supabaseUrl: string, supabaseKey: string, options?: any): any;
}

declare module "npm:google-auth-library@9.6.0" {
  export class GoogleAuth {
    constructor(options?: any);
    getClient(): Promise<{
      getAccessToken(): Promise<{ token: string | null | undefined }>;
    }>;
  }
}

declare module "https://*" {
  const content: any;
  export default content;
}

declare module "npm:*" {
  const content: any;
  export default content;
}

declare namespace Deno {
  export namespace env {
    export function get(key: string): string | undefined;
  }
}
