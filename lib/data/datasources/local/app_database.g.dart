// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalCustomersTable extends LocalCustomers
    with TableInfo<$LocalCustomersTable, LocalCustomer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerCodeMeta = const VerificationMeta(
    'customerCode',
  );
  @override
  late final GeneratedColumn<String> customerCode = GeneratedColumn<String>(
    'customer_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    customerCode,
    phone,
    address,
    notes,
    isActive,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCustomer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('customer_code')) {
      context.handle(
        _customerCodeMeta,
        customerCode.isAcceptableOrUnknown(
          data['customer_code']!,
          _customerCodeMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCustomer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCustomer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      customerCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_code'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $LocalCustomersTable createAlias(String alias) {
    return $LocalCustomersTable(attachedDatabase, alias);
  }
}

class LocalCustomer extends DataClass implements Insertable<LocalCustomer> {
  final String id;
  final String userId;
  final String name;
  final String customerCode;
  final String phone;
  final String address;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const LocalCustomer({
    required this.id,
    required this.userId,
    required this.name,
    required this.customerCode,
    required this.phone,
    required this.address,
    required this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['customer_code'] = Variable<String>(customerCode);
    map['phone'] = Variable<String>(phone);
    map['address'] = Variable<String>(address);
    map['notes'] = Variable<String>(notes);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalCustomersCompanion toCompanion(bool nullToAbsent) {
    return LocalCustomersCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      customerCode: Value(customerCode),
      phone: Value(phone),
      address: Value(address),
      notes: Value(notes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocalCustomer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCustomer(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      customerCode: serializer.fromJson<String>(json['customerCode']),
      phone: serializer.fromJson<String>(json['phone']),
      address: serializer.fromJson<String>(json['address']),
      notes: serializer.fromJson<String>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'customerCode': serializer.toJson<String>(customerCode),
      'phone': serializer.toJson<String>(phone),
      'address': serializer.toJson<String>(address),
      'notes': serializer.toJson<String>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LocalCustomer copyWith({
    String? id,
    String? userId,
    String? name,
    String? customerCode,
    String? phone,
    String? address,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => LocalCustomer(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    customerCode: customerCode ?? this.customerCode,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    notes: notes ?? this.notes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  LocalCustomer copyWithCompanion(LocalCustomersCompanion data) {
    return LocalCustomer(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      customerCode: data.customerCode.present
          ? data.customerCode.value
          : this.customerCode,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCustomer(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('customerCode: $customerCode, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    customerCode,
    phone,
    address,
    notes,
    isActive,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCustomer &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.customerCode == this.customerCode &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class LocalCustomersCompanion extends UpdateCompanion<LocalCustomer> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> customerCode;
  final Value<String> phone;
  final Value<String> address;
  final Value<String> notes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalCustomersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.customerCode = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCustomersCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.customerCode = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalCustomer> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? customerCode,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (customerCode != null) 'customer_code': customerCode,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? customerCode,
    Value<String>? phone,
    Value<String>? address,
    Value<String>? notes,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return LocalCustomersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      customerCode: customerCode ?? this.customerCode,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (customerCode.present) {
      map['customer_code'] = Variable<String>(customerCode.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCustomersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('customerCode: $customerCode, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransactionsTable extends LocalTransactions
    with TableInfo<$LocalTransactionsTable, LocalTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    customerId,
    type,
    amount,
    description,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $LocalTransactionsTable createAlias(String alias) {
    return $LocalTransactionsTable(attachedDatabase, alias);
  }
}

class LocalTransaction extends DataClass
    implements Insertable<LocalTransaction> {
  final String id;
  final String userId;
  final String customerId;
  final String type;
  final double amount;
  final String description;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  const LocalTransaction({
    required this.id,
    required this.userId,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.description,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['customer_id'] = Variable<String>(customerId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['description'] = Variable<String>(description);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      customerId: Value(customerId),
      type: Value(type),
      amount: Value(amount),
      description: Value(description),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocalTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaction(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String>(json['description']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'customerId': serializer.toJson<String>(customerId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String>(description),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LocalTransaction copyWith({
    String? id,
    String? userId,
    String? customerId,
    String? type,
    double? amount,
    String? description,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => LocalTransaction(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    customerId: customerId ?? this.customerId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  LocalTransaction copyWithCompanion(LocalTransactionsCompanion data) {
    return LocalTransaction(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaction(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('customerId: $customerId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    customerId,
    type,
    amount,
    description,
    isDeleted,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaction &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.customerId == this.customerId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class LocalTransactionsCompanion extends UpdateCompanion<LocalTransaction> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> customerId;
  final Value<String> type;
  final Value<double> amount;
  final Value<String> description;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalTransactionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransactionsCompanion.insert({
    required String id,
    required String userId,
    required String customerId,
    required String type,
    required double amount,
    this.description = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       customerId = Value(customerId),
       type = Value(type),
       amount = Value(amount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalTransaction> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? customerId,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (customerId != null) 'customer_id': customerId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? customerId,
    Value<String>? type,
    Value<double>? amount,
    Value<String>? description,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return LocalTransactionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('customerId: $customerId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    recordId,
    operation,
    data,
    createdAt,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['table_name']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityTable;
  final String recordId;
  final String operation;
  final String data;
  final DateTime createdAt;
  final int retryCount;
  const SyncQueueData({
    required this.id,
    required this.entityTable,
    required this.recordId,
    required this.operation,
    required this.data,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['table_name'] = Variable<String>(entityTable);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['data'] = Variable<String>(data);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      recordId: Value(recordId),
      operation: Value(operation),
      data: Value(data),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      data: serializer.fromJson<String>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'data': serializer.toJson<String>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entityTable,
    String? recordId,
    String? operation,
    String? data,
    DateTime? createdAt,
    int? retryCount,
  }) => SyncQueueData(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    recordId: recordId ?? this.recordId,
    operation: operation ?? this.operation,
    data: data ?? this.data,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityTable,
    recordId,
    operation,
    data,
    createdAt,
    retryCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.data == this.data &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityTable;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> data;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityTable,
    required String recordId,
    required String operation,
    required String data,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
  }) : entityTable = Value(entityTable),
       recordId = Value(recordId),
       operation = Value(operation),
       data = Value(data),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityTable,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'table_name': entityTable,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityTable,
    Value<String>? recordId,
    Value<String>? operation,
    Value<String>? data,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityTable.present) {
      map['table_name'] = Variable<String>(entityTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

class $LocalTemporaryCustomersTable extends LocalTemporaryCustomers
    with TableInfo<$LocalTemporaryCustomersTable, LocalTemporaryCustomer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTemporaryCustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtAmountMeta = const VerificationMeta(
    'debtAmount',
  );
  @override
  late final GeneratedColumn<double> debtAmount = GeneratedColumn<double>(
    'debt_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    debtAmount,
    description,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_temporary_customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTemporaryCustomer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('debt_amount')) {
      context.handle(
        _debtAmountMeta,
        debtAmount.isAcceptableOrUnknown(data['debt_amount']!, _debtAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_debtAmountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTemporaryCustomer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTemporaryCustomer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      debtAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}debt_amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalTemporaryCustomersTable createAlias(String alias) {
    return $LocalTemporaryCustomersTable(attachedDatabase, alias);
  }
}

class LocalTemporaryCustomer extends DataClass
    implements Insertable<LocalTemporaryCustomer> {
  final String id;
  final String userId;
  final String name;
  final double debtAmount;
  final String? description;
  final DateTime createdAt;
  const LocalTemporaryCustomer({
    required this.id,
    required this.userId,
    required this.name,
    required this.debtAmount,
    this.description,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['debt_amount'] = Variable<double>(debtAmount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalTemporaryCustomersCompanion toCompanion(bool nullToAbsent) {
    return LocalTemporaryCustomersCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      debtAmount: Value(debtAmount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory LocalTemporaryCustomer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTemporaryCustomer(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      debtAmount: serializer.fromJson<double>(json['debtAmount']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'debtAmount': serializer.toJson<double>(debtAmount),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalTemporaryCustomer copyWith({
    String? id,
    String? userId,
    String? name,
    double? debtAmount,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
  }) => LocalTemporaryCustomer(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    debtAmount: debtAmount ?? this.debtAmount,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalTemporaryCustomer copyWithCompanion(
    LocalTemporaryCustomersCompanion data,
  ) {
    return LocalTemporaryCustomer(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      debtAmount: data.debtAmount.present
          ? data.debtAmount.value
          : this.debtAmount,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTemporaryCustomer(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('debtAmount: $debtAmount, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, name, debtAmount, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTemporaryCustomer &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.debtAmount == this.debtAmount &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class LocalTemporaryCustomersCompanion
    extends UpdateCompanion<LocalTemporaryCustomer> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> debtAmount;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalTemporaryCustomersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.debtAmount = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTemporaryCustomersCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required double debtAmount,
    this.description = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       debtAmount = Value(debtAmount),
       createdAt = Value(createdAt);
  static Insertable<LocalTemporaryCustomer> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? debtAmount,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (debtAmount != null) 'debt_amount': debtAmount,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTemporaryCustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<double>? debtAmount,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalTemporaryCustomersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      debtAmount: debtAmount ?? this.debtAmount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (debtAmount.present) {
      map['debt_amount'] = Variable<double>(debtAmount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTemporaryCustomersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('debtAmount: $debtAmount, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalCustomersTable localCustomers = $LocalCustomersTable(this);
  late final $LocalTransactionsTable localTransactions =
      $LocalTransactionsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $LocalTemporaryCustomersTable localTemporaryCustomers =
      $LocalTemporaryCustomersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localCustomers,
    localTransactions,
    syncQueue,
    localTemporaryCustomers,
  ];
}

typedef $$LocalCustomersTableCreateCompanionBuilder =
    LocalCustomersCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String> customerCode,
      Value<String> phone,
      Value<String> address,
      Value<String> notes,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$LocalCustomersTableUpdateCompanionBuilder =
    LocalCustomersCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> customerCode,
      Value<String> phone,
      Value<String> address,
      Value<String> notes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$LocalCustomersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCustomersTable> {
  $$LocalCustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCustomersTable> {
  $$LocalCustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCustomersTable> {
  $$LocalCustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$LocalCustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCustomersTable,
          LocalCustomer,
          $$LocalCustomersTableFilterComposer,
          $$LocalCustomersTableOrderingComposer,
          $$LocalCustomersTableAnnotationComposer,
          $$LocalCustomersTableCreateCompanionBuilder,
          $$LocalCustomersTableUpdateCompanionBuilder,
          (
            LocalCustomer,
            BaseReferences<_$AppDatabase, $LocalCustomersTable, LocalCustomer>,
          ),
          LocalCustomer,
          PrefetchHooks Function()
        > {
  $$LocalCustomersTableTableManager(
    _$AppDatabase db,
    $LocalCustomersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> customerCode = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCustomersCompanion(
                id: id,
                userId: userId,
                name: name,
                customerCode: customerCode,
                phone: phone,
                address: address,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String> customerCode = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCustomersCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                customerCode: customerCode,
                phone: phone,
                address: address,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCustomersTable,
      LocalCustomer,
      $$LocalCustomersTableFilterComposer,
      $$LocalCustomersTableOrderingComposer,
      $$LocalCustomersTableAnnotationComposer,
      $$LocalCustomersTableCreateCompanionBuilder,
      $$LocalCustomersTableUpdateCompanionBuilder,
      (
        LocalCustomer,
        BaseReferences<_$AppDatabase, $LocalCustomersTable, LocalCustomer>,
      ),
      LocalCustomer,
      PrefetchHooks Function()
    >;
typedef $$LocalTransactionsTableCreateCompanionBuilder =
    LocalTransactionsCompanion Function({
      required String id,
      required String userId,
      required String customerId,
      required String type,
      required double amount,
      Value<String> description,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$LocalTransactionsTableUpdateCompanionBuilder =
    LocalTransactionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> customerId,
      Value<String> type,
      Value<double> amount,
      Value<String> description,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$LocalTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$LocalTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTransactionsTable,
          LocalTransaction,
          $$LocalTransactionsTableFilterComposer,
          $$LocalTransactionsTableOrderingComposer,
          $$LocalTransactionsTableAnnotationComposer,
          $$LocalTransactionsTableCreateCompanionBuilder,
          $$LocalTransactionsTableUpdateCompanionBuilder,
          (
            LocalTransaction,
            BaseReferences<
              _$AppDatabase,
              $LocalTransactionsTable,
              LocalTransaction
            >,
          ),
          LocalTransaction,
          PrefetchHooks Function()
        > {
  $$LocalTransactionsTableTableManager(
    _$AppDatabase db,
    $LocalTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionsCompanion(
                id: id,
                userId: userId,
                customerId: customerId,
                type: type,
                amount: amount,
                description: description,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String customerId,
                required String type,
                required double amount,
                Value<String> description = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionsCompanion.insert(
                id: id,
                userId: userId,
                customerId: customerId,
                type: type,
                amount: amount,
                description: description,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTransactionsTable,
      LocalTransaction,
      $$LocalTransactionsTableFilterComposer,
      $$LocalTransactionsTableOrderingComposer,
      $$LocalTransactionsTableAnnotationComposer,
      $$LocalTransactionsTableCreateCompanionBuilder,
      $$LocalTransactionsTableUpdateCompanionBuilder,
      (
        LocalTransaction,
        BaseReferences<
          _$AppDatabase,
          $LocalTransactionsTable,
          LocalTransaction
        >,
      ),
      LocalTransaction,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityTable,
      required String recordId,
      required String operation,
      required String data,
      required DateTime createdAt,
      Value<int> retryCount,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityTable,
      Value<String> recordId,
      Value<String> operation,
      Value<String> data,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityTable: entityTable,
                recordId: recordId,
                operation: operation,
                data: data,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityTable,
                required String recordId,
                required String operation,
                required String data,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityTable: entityTable,
                recordId: recordId,
                operation: operation,
                data: data,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$LocalTemporaryCustomersTableCreateCompanionBuilder =
    LocalTemporaryCustomersCompanion Function({
      required String id,
      required String userId,
      required String name,
      required double debtAmount,
      Value<String?> description,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalTemporaryCustomersTableUpdateCompanionBuilder =
    LocalTemporaryCustomersCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<double> debtAmount,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalTemporaryCustomersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTemporaryCustomersTable> {
  $$LocalTemporaryCustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get debtAmount => $composableBuilder(
    column: $table.debtAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTemporaryCustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTemporaryCustomersTable> {
  $$LocalTemporaryCustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get debtAmount => $composableBuilder(
    column: $table.debtAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTemporaryCustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTemporaryCustomersTable> {
  $$LocalTemporaryCustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get debtAmount => $composableBuilder(
    column: $table.debtAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalTemporaryCustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTemporaryCustomersTable,
          LocalTemporaryCustomer,
          $$LocalTemporaryCustomersTableFilterComposer,
          $$LocalTemporaryCustomersTableOrderingComposer,
          $$LocalTemporaryCustomersTableAnnotationComposer,
          $$LocalTemporaryCustomersTableCreateCompanionBuilder,
          $$LocalTemporaryCustomersTableUpdateCompanionBuilder,
          (
            LocalTemporaryCustomer,
            BaseReferences<
              _$AppDatabase,
              $LocalTemporaryCustomersTable,
              LocalTemporaryCustomer
            >,
          ),
          LocalTemporaryCustomer,
          PrefetchHooks Function()
        > {
  $$LocalTemporaryCustomersTableTableManager(
    _$AppDatabase db,
    $LocalTemporaryCustomersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTemporaryCustomersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalTemporaryCustomersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalTemporaryCustomersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> debtAmount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTemporaryCustomersCompanion(
                id: id,
                userId: userId,
                name: name,
                debtAmount: debtAmount,
                description: description,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required double debtAmount,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalTemporaryCustomersCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                debtAmount: debtAmount,
                description: description,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTemporaryCustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTemporaryCustomersTable,
      LocalTemporaryCustomer,
      $$LocalTemporaryCustomersTableFilterComposer,
      $$LocalTemporaryCustomersTableOrderingComposer,
      $$LocalTemporaryCustomersTableAnnotationComposer,
      $$LocalTemporaryCustomersTableCreateCompanionBuilder,
      $$LocalTemporaryCustomersTableUpdateCompanionBuilder,
      (
        LocalTemporaryCustomer,
        BaseReferences<
          _$AppDatabase,
          $LocalTemporaryCustomersTable,
          LocalTemporaryCustomer
        >,
      ),
      LocalTemporaryCustomer,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalCustomersTableTableManager get localCustomers =>
      $$LocalCustomersTableTableManager(_db, _db.localCustomers);
  $$LocalTransactionsTableTableManager get localTransactions =>
      $$LocalTransactionsTableTableManager(_db, _db.localTransactions);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$LocalTemporaryCustomersTableTableManager get localTemporaryCustomers =>
      $$LocalTemporaryCustomersTableTableManager(
        _db,
        _db.localTemporaryCustomers,
      );
}
