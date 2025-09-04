// 🌐 LingoSphere - API Gateway Models
// Data structures and models for Global API Gateway & Integration Hub


// ===== CORE GATEWAY MODELS =====

class GatewayConfiguration {
  final String name;
  final String description;
  final String version;
  final RoutingOptions routingOptions;
  final LoadBalancingOptions loadBalancingOptions;
  final AuthenticationOptions authenticationOptions;
  final AuthorizationOptions authorizationOptions;
  final RateLimitingOptions rateLimitingOptions;
  final ProcessingOptions processingOptions;
  final TransformationOptions transformationOptions;
  final MonitoringOptions monitoringOptions;
  final CachingOptions cachingOptions;
  final SecurityOptions securityOptions;
  final Map<String, dynamic> customSettings;

  GatewayConfiguration({
    required this.name,
    required this.description,
    required this.version,
    required this.routingOptions,
    required this.loadBalancingOptions,
    required this.authenticationOptions,
    required this.authorizationOptions,
    required this.rateLimitingOptions,
    required this.processingOptions,
    required this.transformationOptions,
    required this.monitoringOptions,
    required this.cachingOptions,
    required this.securityOptions,
    this.customSettings = const {},
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'version': version,
        'routingOptions': routingOptions.toJson(),
        'loadBalancingOptions': loadBalancingOptions.toJson(),
        'authenticationOptions': authenticationOptions.toJson(),
        'authorizationOptions': authorizationOptions.toJson(),
        'rateLimitingOptions': rateLimitingOptions.toJson(),
        'processingOptions': processingOptions.toJson(),
        'transformationOptions': transformationOptions.toJson(),
        'monitoringOptions': monitoringOptions.toJson(),
        'cachingOptions': cachingOptions.toJson(),
        'securityOptions': securityOptions.toJson(),
        'customSettings': customSettings,
      };

  factory GatewayConfiguration.fromJson(Map<String, dynamic> json) =>
      GatewayConfiguration(
        name: json['name'],
        description: json['description'],
        version: json['version'],
        routingOptions: RoutingOptions.fromJson(json['routingOptions']),
        loadBalancingOptions:
            LoadBalancingOptions.fromJson(json['loadBalancingOptions']),
        authenticationOptions:
            AuthenticationOptions.fromJson(json['authenticationOptions']),
        authorizationOptions:
            AuthorizationOptions.fromJson(json['authorizationOptions']),
        rateLimitingOptions:
            RateLimitingOptions.fromJson(json['rateLimitingOptions']),
        processingOptions:
            ProcessingOptions.fromJson(json['processingOptions']),
        transformationOptions:
            TransformationOptions.fromJson(json['transformationOptions']),
        monitoringOptions:
            MonitoringOptions.fromJson(json['monitoringOptions']),
        cachingOptions: CachingOptions.fromJson(json['cachingOptions']),
        securityOptions: SecurityOptions.fromJson(json['securityOptions']),
        customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
      );
}

// ===== ROUTING MODELS =====

class RoutingOptions {
  final RoutingStrategy strategy;
  final List<RoutingRule> rules;
  final PathMatchingMode pathMatching;
  final bool enableWildcards;
  final int priority;
  final Map<String, String> headers;

  RoutingOptions({
    required this.strategy,
    required this.rules,
    required this.pathMatching,
    required this.enableWildcards,
    required this.priority,
    required this.headers,
  });

  Map<String, dynamic> toJson() => {
        'strategy': strategy.toString(),
        'rules': rules.map((r) => r.toJson()).toList(),
        'pathMatching': pathMatching.toString(),
        'enableWildcards': enableWildcards,
        'priority': priority,
        'headers': headers,
      };

  factory RoutingOptions.fromJson(Map<String, dynamic> json) => RoutingOptions(
        strategy: RoutingStrategy.values
            .firstWhere((s) => s.toString() == json['strategy']),
        rules: (json['rules'] as List)
            .map((r) => RoutingRule.fromJson(r))
            .toList(),
        pathMatching: PathMatchingMode.values
            .firstWhere((p) => p.toString() == json['pathMatching']),
        enableWildcards: json['enableWildcards'],
        priority: json['priority'],
        headers: Map<String, String>.from(json['headers']),
      );
}

class RoutingRule {
  final String path;
  final String method;
  final String targetService;
  final Map<String, String> conditions;
  final int priority;
  final bool isActive;

  RoutingRule({
    required this.path,
    required this.method,
    required this.targetService,
    required this.conditions,
    required this.priority,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'method': method,
        'targetService': targetService,
        'conditions': conditions,
        'priority': priority,
        'isActive': isActive,
      };

  factory RoutingRule.fromJson(Map<String, dynamic> json) => RoutingRule(
        path: json['path'],
        method: json['method'],
        targetService: json['targetService'],
        conditions: Map<String, String>.from(json['conditions']),
        priority: json['priority'],
        isActive: json['isActive'],
      );
}

// ===== LOAD BALANCING MODELS =====

class LoadBalancingOptions {
  final LoadBalancingStrategy strategy;
  final List<UpstreamServer> servers;
  final HealthCheckConfig healthCheck;
  final int maxRetries;
  final Duration timeout;
  final bool enableStickySessions;

  LoadBalancingOptions({
    required this.strategy,
    required this.servers,
    required this.healthCheck,
    required this.maxRetries,
    required this.timeout,
    required this.enableStickySessions,
  });

  Map<String, dynamic> toJson() => {
        'strategy': strategy.toString(),
        'servers': servers.map((s) => s.toJson()).toList(),
        'healthCheck': healthCheck.toJson(),
        'maxRetries': maxRetries,
        'timeout': timeout.inMilliseconds,
        'enableStickySessions': enableStickySessions,
      };

  factory LoadBalancingOptions.fromJson(Map<String, dynamic> json) =>
      LoadBalancingOptions(
        strategy: LoadBalancingStrategy.values
            .firstWhere((s) => s.toString() == json['strategy']),
        servers: (json['servers'] as List)
            .map((s) => UpstreamServer.fromJson(s))
            .toList(),
        healthCheck: HealthCheckConfig.fromJson(json['healthCheck']),
        maxRetries: json['maxRetries'],
        timeout: Duration(milliseconds: json['timeout']),
        enableStickySessions: json['enableStickySessions'],
      );
}

class UpstreamServer {
  final String id;
  final String host;
  final int port;
  final int weight;
  final ServerStatus status;
  final Map<String, String> metadata;

  UpstreamServer({
    required this.id,
    required this.host,
    required this.port,
    required this.weight,
    required this.status,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'host': host,
        'port': port,
        'weight': weight,
        'status': status.toString(),
        'metadata': metadata,
      };

  factory UpstreamServer.fromJson(Map<String, dynamic> json) => UpstreamServer(
        id: json['id'],
        host: json['host'],
        port: json['port'],
        weight: json['weight'],
        status: ServerStatus.values
            .firstWhere((s) => s.toString() == json['status']),
        metadata: Map<String, String>.from(json['metadata']),
      );
}

// ===== AUTHENTICATION MODELS =====

class AuthenticationOptions {
  final List<AuthenticationMethod> methods;
  final TokenValidationConfig tokenValidation;
  final JWTConfig jwtConfig;
  final OAuthConfig oauthConfig;
  final APIKeyConfig apiKeyConfig;
  final bool requireAuthentication;

  AuthenticationOptions({
    required this.methods,
    required this.tokenValidation,
    required this.jwtConfig,
    required this.oauthConfig,
    required this.apiKeyConfig,
    required this.requireAuthentication,
  });

  Map<String, dynamic> toJson() => {
        'methods': methods.map((m) => m.toString()).toList(),
        'tokenValidation': tokenValidation.toJson(),
        'jwtConfig': jwtConfig.toJson(),
        'oauthConfig': oauthConfig.toJson(),
        'apiKeyConfig': apiKeyConfig.toJson(),
        'requireAuthentication': requireAuthentication,
      };

  factory AuthenticationOptions.fromJson(Map<String, dynamic> json) =>
      AuthenticationOptions(
        methods: (json['methods'] as List)
            .map((m) => AuthenticationMethod.values
                .firstWhere((method) => method.toString() == m))
            .toList(),
        tokenValidation:
            TokenValidationConfig.fromJson(json['tokenValidation']),
        jwtConfig: JWTConfig.fromJson(json['jwtConfig']),
        oauthConfig: OAuthConfig.fromJson(json['oauthConfig']),
        apiKeyConfig: APIKeyConfig.fromJson(json['apiKeyConfig']),
        requireAuthentication: json['requireAuthentication'],
      );
}

// ===== AUTHORIZATION MODELS =====

class AuthorizationOptions {
  final AuthorizationStrategy strategy;
  final List<AuthorizationPolicy> policies;
  final RBACConfig rbacConfig;
  final ABACConfig abacConfig;
  final bool enablePermissionCaching;

  AuthorizationOptions({
    required this.strategy,
    required this.policies,
    required this.rbacConfig,
    required this.abacConfig,
    required this.enablePermissionCaching,
  });

  Map<String, dynamic> toJson() => {
        'strategy': strategy.toString(),
        'policies': policies.map((p) => p.toJson()).toList(),
        'rbacConfig': rbacConfig.toJson(),
        'abacConfig': abacConfig.toJson(),
        'enablePermissionCaching': enablePermissionCaching,
      };

  factory AuthorizationOptions.fromJson(Map<String, dynamic> json) =>
      AuthorizationOptions(
        strategy: AuthorizationStrategy.values
            .firstWhere((s) => s.toString() == json['strategy']),
        policies: (json['policies'] as List)
            .map((p) => AuthorizationPolicy.fromJson(p))
            .toList(),
        rbacConfig: RBACConfig.fromJson(json['rbacConfig']),
        abacConfig: ABACConfig.fromJson(json['abacConfig']),
        enablePermissionCaching: json['enablePermissionCaching'],
      );
}

// ===== RATE LIMITING MODELS =====

class RateLimitingOptions {
  final List<RateLimitRule> rules;
  final RateLimitStrategy strategy;
  final int windowSize;
  final TimeUnit timeUnit;
  final bool enableBurstCapacity;
  final int burstCapacity;

  RateLimitingOptions({
    required this.rules,
    required this.strategy,
    required this.windowSize,
    required this.timeUnit,
    required this.enableBurstCapacity,
    required this.burstCapacity,
  });

  Map<String, dynamic> toJson() => {
        'rules': rules.map((r) => r.toJson()).toList(),
        'strategy': strategy.toString(),
        'windowSize': windowSize,
        'timeUnit': timeUnit.toString(),
        'enableBurstCapacity': enableBurstCapacity,
        'burstCapacity': burstCapacity,
      };

  factory RateLimitingOptions.fromJson(Map<String, dynamic> json) =>
      RateLimitingOptions(
        rules: (json['rules'] as List)
            .map((r) => RateLimitRule.fromJson(r))
            .toList(),
        strategy: RateLimitStrategy.values
            .firstWhere((s) => s.toString() == json['strategy']),
        windowSize: json['windowSize'],
        timeUnit:
            TimeUnit.values.firstWhere((t) => t.toString() == json['timeUnit']),
        enableBurstCapacity: json['enableBurstCapacity'],
        burstCapacity: json['burstCapacity'],
      );
}

// ===== INTEGRATION MODELS =====

class IntegrationConfiguration {
  final WebhookOptions webhookOptions;
  final EventOptions eventOptions;
  final SyncOptions syncOptions;
  final SecurityOptions securityOptions;
  final RetryOptions retryOptions;
  final Map<String, dynamic> platformSpecificConfig;

  IntegrationConfiguration({
    required this.webhookOptions,
    required this.eventOptions,
    required this.syncOptions,
    required this.securityOptions,
    required this.retryOptions,
    this.platformSpecificConfig = const {},
  });

  Map<String, dynamic> toJson() => {
        'webhookOptions': webhookOptions.toJson(),
        'eventOptions': eventOptions.toJson(),
        'syncOptions': syncOptions.toJson(),
        'securityOptions': securityOptions.toJson(),
        'retryOptions': retryOptions.toJson(),
        'platformSpecificConfig': platformSpecificConfig,
      };

  factory IntegrationConfiguration.fromJson(Map<String, dynamic> json) =>
      IntegrationConfiguration(
        webhookOptions: WebhookOptions.fromJson(json['webhookOptions']),
        eventOptions: EventOptions.fromJson(json['eventOptions']),
        syncOptions: SyncOptions.fromJson(json['syncOptions']),
        securityOptions: SecurityOptions.fromJson(json['securityOptions']),
        retryOptions: RetryOptions.fromJson(json['retryOptions']),
        platformSpecificConfig:
            Map<String, dynamic>.from(json['platformSpecificConfig'] ?? {}),
      );
}

// ===== WEBHOOK MODELS =====

class WebhookOptions {
  final List<WebhookEndpoint> endpoints;
  final WebhookSecurity security;
  final RetryPolicy retryPolicy;
  final int timeoutSeconds;
  final bool enableDeliveryTracking;

  WebhookOptions({
    required this.endpoints,
    required this.security,
    required this.retryPolicy,
    required this.timeoutSeconds,
    required this.enableDeliveryTracking,
  });

  Map<String, dynamic> toJson() => {
        'endpoints': endpoints.map((e) => e.toJson()).toList(),
        'security': security.toJson(),
        'retryPolicy': retryPolicy.toJson(),
        'timeoutSeconds': timeoutSeconds,
        'enableDeliveryTracking': enableDeliveryTracking,
      };

  factory WebhookOptions.fromJson(Map<String, dynamic> json) => WebhookOptions(
        endpoints: (json['endpoints'] as List)
            .map((e) => WebhookEndpoint.fromJson(e))
            .toList(),
        security: WebhookSecurity.fromJson(json['security']),
        retryPolicy: RetryPolicy.fromJson(json['retryPolicy']),
        timeoutSeconds: json['timeoutSeconds'],
        enableDeliveryTracking: json['enableDeliveryTracking'],
      );
}

// ===== EVENT MODELS =====

class EventOptions {
  final List<EventFilter> filters;
  final EventDeliveryMode deliveryMode;
  final EventSerialization serialization;
  final bool enableEventBatching;
  final int batchSize;
  final Duration batchTimeout;

  EventOptions({
    required this.filters,
    required this.deliveryMode,
    required this.serialization,
    required this.enableEventBatching,
    required this.batchSize,
    required this.batchTimeout,
  });

  Map<String, dynamic> toJson() => {
        'filters': filters.map((f) => f.toJson()).toList(),
        'deliveryMode': deliveryMode.toString(),
        'serialization': serialization.toString(),
        'enableEventBatching': enableEventBatching,
        'batchSize': batchSize,
        'batchTimeout': batchTimeout.inMilliseconds,
      };

  factory EventOptions.fromJson(Map<String, dynamic> json) => EventOptions(
        filters: (json['filters'] as List)
            .map((f) => EventFilter.fromJson(f))
            .toList(),
        deliveryMode: EventDeliveryMode.values
            .firstWhere((d) => d.toString() == json['deliveryMode']),
        serialization: EventSerialization.values
            .firstWhere((s) => s.toString() == json['serialization']),
        enableEventBatching: json['enableEventBatching'],
        batchSize: json['batchSize'],
        batchTimeout: Duration(milliseconds: json['batchTimeout']),
      );
}

// ===== SYNC MODELS =====

class SyncOptions {
  final SyncStrategy strategy;
  final Duration syncInterval;
  final List<SyncMapping> mappings;
  final ConflictResolution conflictResolution;
  final bool enableBidirectionalSync;
  final DataTransformation transformation;

  SyncOptions({
    required this.strategy,
    required this.syncInterval,
    required this.mappings,
    required this.conflictResolution,
    required this.enableBidirectionalSync,
    required this.transformation,
  });

  Map<String, dynamic> toJson() => {
        'strategy': strategy.toString(),
        'syncInterval': syncInterval.inMilliseconds,
        'mappings': mappings.map((m) => m.toJson()).toList(),
        'conflictResolution': conflictResolution.toString(),
        'enableBidirectionalSync': enableBidirectionalSync,
        'transformation': transformation.toJson(),
      };

  factory SyncOptions.fromJson(Map<String, dynamic> json) => SyncOptions(
        strategy: SyncStrategy.values
            .firstWhere((s) => s.toString() == json['strategy']),
        syncInterval: Duration(milliseconds: json['syncInterval']),
        mappings: (json['mappings'] as List)
            .map((m) => SyncMapping.fromJson(m))
            .toList(),
        conflictResolution: ConflictResolution.values
            .firstWhere((c) => c.toString() == json['conflictResolution']),
        enableBidirectionalSync: json['enableBidirectionalSync'],
        transformation: DataTransformation.fromJson(json['transformation']),
      );
}

// ===== ENUMS =====

enum RoutingStrategy {
  roundRobin,
  weighted,
  leastConnections,
  ipHash,
  geographic
}

enum PathMatchingMode { exact, prefix, regex, wildcard }

enum LoadBalancingStrategy {
  roundRobin,
  weighted,
  leastConnections,
  ipHash,
  random
}

enum ServerStatus { active, inactive, draining, maintenance }

enum AuthenticationMethod { jwt, oauth2, apiKey, basic, bearer, custom }

enum AuthorizationStrategy { rbac, abac, custom }

enum RateLimitStrategy { fixedWindow, slidingWindow, tokenBucket, leakyBucket }

enum TimeUnit { second, minute, hour, day }

enum EventDeliveryMode { push, pull, stream }

enum EventSerialization { json, protobuf, avro, xml }

enum SyncStrategy { realTime, scheduled, triggered, hybrid }

enum ConflictResolution { sourceWins, targetWins, merge, manual }

// ===== SUPPORTING MODELS =====

class HealthCheckConfig {
  final String path;
  final Duration interval;
  final Duration timeout;
  final int healthyThreshold;
  final int unhealthyThreshold;

  HealthCheckConfig({
    required this.path,
    required this.interval,
    required this.timeout,
    required this.healthyThreshold,
    required this.unhealthyThreshold,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'interval': interval.inMilliseconds,
        'timeout': timeout.inMilliseconds,
        'healthyThreshold': healthyThreshold,
        'unhealthyThreshold': unhealthyThreshold,
      };

  factory HealthCheckConfig.fromJson(Map<String, dynamic> json) =>
      HealthCheckConfig(
        path: json['path'],
        interval: Duration(milliseconds: json['interval']),
        timeout: Duration(milliseconds: json['timeout']),
        healthyThreshold: json['healthyThreshold'],
        unhealthyThreshold: json['unhealthyThreshold'],
      );
}

class TokenValidationConfig {
  final String issuer;
  final String audience;
  final Duration clockSkew;
  final bool validateExpiration;
  final bool validateNotBefore;

  TokenValidationConfig({
    required this.issuer,
    required this.audience,
    required this.clockSkew,
    required this.validateExpiration,
    required this.validateNotBefore,
  });

  Map<String, dynamic> toJson() => {
        'issuer': issuer,
        'audience': audience,
        'clockSkew': clockSkew.inMilliseconds,
        'validateExpiration': validateExpiration,
        'validateNotBefore': validateNotBefore,
      };

  factory TokenValidationConfig.fromJson(Map<String, dynamic> json) =>
      TokenValidationConfig(
        issuer: json['issuer'],
        audience: json['audience'],
        clockSkew: Duration(milliseconds: json['clockSkew']),
        validateExpiration: json['validateExpiration'],
        validateNotBefore: json['validateNotBefore'],
      );
}

class JWTConfig {
  final String secretKey;
  final String algorithm;
  final Duration expiresIn;
  final String issuer;
  final String audience;

  JWTConfig({
    required this.secretKey,
    required this.algorithm,
    required this.expiresIn,
    required this.issuer,
    required this.audience,
  });

  Map<String, dynamic> toJson() => {
        'secretKey': secretKey,
        'algorithm': algorithm,
        'expiresIn': expiresIn.inSeconds,
        'issuer': issuer,
        'audience': audience,
      };

  factory JWTConfig.fromJson(Map<String, dynamic> json) => JWTConfig(
        secretKey: json['secretKey'],
        algorithm: json['algorithm'],
        expiresIn: Duration(seconds: json['expiresIn']),
        issuer: json['issuer'],
        audience: json['audience'],
      );
}

class OAuthConfig {
  final String clientId;
  final String clientSecret;
  final String authorizationUrl;
  final String tokenUrl;
  final List<String> scopes;
  final String redirectUri;

  OAuthConfig({
    required this.clientId,
    required this.clientSecret,
    required this.authorizationUrl,
    required this.tokenUrl,
    required this.scopes,
    required this.redirectUri,
  });

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'clientSecret': clientSecret,
        'authorizationUrl': authorizationUrl,
        'tokenUrl': tokenUrl,
        'scopes': scopes,
        'redirectUri': redirectUri,
      };

  factory OAuthConfig.fromJson(Map<String, dynamic> json) => OAuthConfig(
        clientId: json['clientId'],
        clientSecret: json['clientSecret'],
        authorizationUrl: json['authorizationUrl'],
        tokenUrl: json['tokenUrl'],
        scopes: List<String>.from(json['scopes']),
        redirectUri: json['redirectUri'],
      );
}

class APIKeyConfig {
  final String headerName;
  final String queryParamName;
  final bool allowInQuery;
  final bool allowInHeader;
  final KeyValidationMode validationMode;

  APIKeyConfig({
    required this.headerName,
    required this.queryParamName,
    required this.allowInQuery,
    required this.allowInHeader,
    required this.validationMode,
  });

  Map<String, dynamic> toJson() => {
        'headerName': headerName,
        'queryParamName': queryParamName,
        'allowInQuery': allowInQuery,
        'allowInHeader': allowInHeader,
        'validationMode': validationMode.toString(),
      };

  factory APIKeyConfig.fromJson(Map<String, dynamic> json) => APIKeyConfig(
        headerName: json['headerName'],
        queryParamName: json['queryParamName'],
        allowInQuery: json['allowInQuery'],
        allowInHeader: json['allowInHeader'],
        validationMode: KeyValidationMode.values
            .firstWhere((k) => k.toString() == json['validationMode']),
      );
}

class AuthorizationPolicy {
  final String name;
  final String resource;
  final List<String> actions;
  final Map<String, dynamic> conditions;
  final PolicyEffect effect;

  AuthorizationPolicy({
    required this.name,
    required this.resource,
    required this.actions,
    required this.conditions,
    required this.effect,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'resource': resource,
        'actions': actions,
        'conditions': conditions,
        'effect': effect.toString(),
      };

  factory AuthorizationPolicy.fromJson(Map<String, dynamic> json) =>
      AuthorizationPolicy(
        name: json['name'],
        resource: json['resource'],
        actions: List<String>.from(json['actions']),
        conditions: Map<String, dynamic>.from(json['conditions']),
        effect: PolicyEffect.values
            .firstWhere((e) => e.toString() == json['effect']),
      );
}

class RBACConfig {
  final List<Role> roles;
  final List<Permission> permissions;
  final bool enableInheritance;
  final String defaultRole;

  RBACConfig({
    required this.roles,
    required this.permissions,
    required this.enableInheritance,
    required this.defaultRole,
  });

  Map<String, dynamic> toJson() => {
        'roles': roles.map((r) => r.toJson()).toList(),
        'permissions': permissions.map((p) => p.toJson()).toList(),
        'enableInheritance': enableInheritance,
        'defaultRole': defaultRole,
      };

  factory RBACConfig.fromJson(Map<String, dynamic> json) => RBACConfig(
        roles: (json['roles'] as List).map((r) => Role.fromJson(r)).toList(),
        permissions: (json['permissions'] as List)
            .map((p) => Permission.fromJson(p))
            .toList(),
        enableInheritance: json['enableInheritance'],
        defaultRole: json['defaultRole'],
      );
}

class ABACConfig {
  final List<AttributeDefinition> attributes;
  final List<PolicyRule> rules;
  final bool enableDynamicAttributes;
  final String decisionPoint;

  ABACConfig({
    required this.attributes,
    required this.rules,
    required this.enableDynamicAttributes,
    required this.decisionPoint,
  });

  Map<String, dynamic> toJson() => {
        'attributes': attributes.map((a) => a.toJson()).toList(),
        'rules': rules.map((r) => r.toJson()).toList(),
        'enableDynamicAttributes': enableDynamicAttributes,
        'decisionPoint': decisionPoint,
      };

  factory ABACConfig.fromJson(Map<String, dynamic> json) => ABACConfig(
        attributes: (json['attributes'] as List)
            .map((a) => AttributeDefinition.fromJson(a))
            .toList(),
        rules:
            (json['rules'] as List).map((r) => PolicyRule.fromJson(r)).toList(),
        enableDynamicAttributes: json['enableDynamicAttributes'],
        decisionPoint: json['decisionPoint'],
      );
}

class RateLimitRule {
  final String name;
  final String pattern;
  final int limit;
  final Duration window;
  final List<String> exemptions;
  final bool isActive;

  RateLimitRule({
    required this.name,
    required this.pattern,
    required this.limit,
    required this.window,
    required this.exemptions,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'pattern': pattern,
        'limit': limit,
        'window': window.inMilliseconds,
        'exemptions': exemptions,
        'isActive': isActive,
      };

  factory RateLimitRule.fromJson(Map<String, dynamic> json) => RateLimitRule(
        name: json['name'],
        pattern: json['pattern'],
        limit: json['limit'],
        window: Duration(milliseconds: json['window']),
        exemptions: List<String>.from(json['exemptions']),
        isActive: json['isActive'],
      );
}

// ===== PROCESSING & TRANSFORMATION MODELS =====

class ProcessingOptions {
  final List<RequestTransform> requestTransforms;
  final List<ResponseTransform> responseTransforms;
  final ValidationConfig validation;
  final CompressionConfig compression;
  final bool enableCorrelationId;

  ProcessingOptions({
    required this.requestTransforms,
    required this.responseTransforms,
    required this.validation,
    required this.compression,
    required this.enableCorrelationId,
  });

  Map<String, dynamic> toJson() => {
        'requestTransforms': requestTransforms.map((t) => t.toJson()).toList(),
        'responseTransforms':
            responseTransforms.map((t) => t.toJson()).toList(),
        'validation': validation.toJson(),
        'compression': compression.toJson(),
        'enableCorrelationId': enableCorrelationId,
      };

  factory ProcessingOptions.fromJson(Map<String, dynamic> json) =>
      ProcessingOptions(
        requestTransforms: (json['requestTransforms'] as List)
            .map((t) => RequestTransform.fromJson(t))
            .toList(),
        responseTransforms: (json['responseTransforms'] as List)
            .map((t) => ResponseTransform.fromJson(t))
            .toList(),
        validation: ValidationConfig.fromJson(json['validation']),
        compression: CompressionConfig.fromJson(json['compression']),
        enableCorrelationId: json['enableCorrelationId'],
      );
}

class TransformationOptions {
  final List<DataMapper> mappers;
  final FormatConverter formatConverter;
  final ContentEnricher contentEnricher;
  final bool enableSchemaValidation;
  final SchemaRegistry schemaRegistry;

  TransformationOptions({
    required this.mappers,
    required this.formatConverter,
    required this.contentEnricher,
    required this.enableSchemaValidation,
    required this.schemaRegistry,
  });

  Map<String, dynamic> toJson() => {
        'mappers': mappers.map((m) => m.toJson()).toList(),
        'formatConverter': formatConverter.toJson(),
        'contentEnricher': contentEnricher.toJson(),
        'enableSchemaValidation': enableSchemaValidation,
        'schemaRegistry': schemaRegistry.toJson(),
      };

  factory TransformationOptions.fromJson(Map<String, dynamic> json) =>
      TransformationOptions(
        mappers: (json['mappers'] as List)
            .map((m) => DataMapper.fromJson(m))
            .toList(),
        formatConverter: FormatConverter.fromJson(json['formatConverter']),
        contentEnricher: ContentEnricher.fromJson(json['contentEnricher']),
        enableSchemaValidation: json['enableSchemaValidation'],
        schemaRegistry: SchemaRegistry.fromJson(json['schemaRegistry']),
      );
}

// ===== MONITORING & OBSERVABILITY MODELS =====

class MonitoringOptions {
  final MetricsConfig metricsConfig;
  final LoggingConfig loggingConfig;
  final TracingConfig tracingConfig;
  final AlertingConfig alertingConfig;
  final bool enableHealthChecks;

  MonitoringOptions({
    required this.metricsConfig,
    required this.loggingConfig,
    required this.tracingConfig,
    required this.alertingConfig,
    required this.enableHealthChecks,
  });

  Map<String, dynamic> toJson() => {
        'metricsConfig': metricsConfig.toJson(),
        'loggingConfig': loggingConfig.toJson(),
        'tracingConfig': tracingConfig.toJson(),
        'alertingConfig': alertingConfig.toJson(),
        'enableHealthChecks': enableHealthChecks,
      };

  factory MonitoringOptions.fromJson(Map<String, dynamic> json) =>
      MonitoringOptions(
        metricsConfig: MetricsConfig.fromJson(json['metricsConfig']),
        loggingConfig: LoggingConfig.fromJson(json['loggingConfig']),
        tracingConfig: TracingConfig.fromJson(json['tracingConfig']),
        alertingConfig: AlertingConfig.fromJson(json['alertingConfig']),
        enableHealthChecks: json['enableHealthChecks'],
      );
}

// ===== CACHING MODELS =====

class CachingOptions {
  final CacheStrategy strategy;
  final Duration defaultTTL;
  final int maxCacheSize;
  final List<CacheRule> rules;
  final EvictionPolicy evictionPolicy;
  final bool enableDistributedCache;

  CachingOptions({
    required this.strategy,
    required this.defaultTTL,
    required this.maxCacheSize,
    required this.rules,
    required this.evictionPolicy,
    required this.enableDistributedCache,
  });

  Map<String, dynamic> toJson() => {
        'strategy': strategy.toString(),
        'defaultTTL': defaultTTL.inSeconds,
        'maxCacheSize': maxCacheSize,
        'rules': rules.map((r) => r.toJson()).toList(),
        'evictionPolicy': evictionPolicy.toString(),
        'enableDistributedCache': enableDistributedCache,
      };

  factory CachingOptions.fromJson(Map<String, dynamic> json) => CachingOptions(
        strategy: CacheStrategy.values
            .firstWhere((s) => s.toString() == json['strategy']),
        defaultTTL: Duration(seconds: json['defaultTTL']),
        maxCacheSize: json['maxCacheSize'],
        rules:
            (json['rules'] as List).map((r) => CacheRule.fromJson(r)).toList(),
        evictionPolicy: EvictionPolicy.values
            .firstWhere((e) => e.toString() == json['evictionPolicy']),
        enableDistributedCache: json['enableDistributedCache'],
      );
}

// ===== SECURITY MODELS =====

class SecurityOptions {
  final TLSConfig tlsConfig;
  final CORSConfig corsConfig;
  final CSPConfig cspConfig;
  final IPWhitelistConfig ipWhitelist;
  final SecurityHeaders securityHeaders;
  final bool enableSecurityAuditing;

  SecurityOptions({
    required this.tlsConfig,
    required this.corsConfig,
    required this.cspConfig,
    required this.ipWhitelist,
    required this.securityHeaders,
    required this.enableSecurityAuditing,
  });

  Map<String, dynamic> toJson() => {
        'tlsConfig': tlsConfig.toJson(),
        'corsConfig': corsConfig.toJson(),
        'cspConfig': cspConfig.toJson(),
        'ipWhitelist': ipWhitelist.toJson(),
        'securityHeaders': securityHeaders.toJson(),
        'enableSecurityAuditing': enableSecurityAuditing,
      };

  factory SecurityOptions.fromJson(Map<String, dynamic> json) =>
      SecurityOptions(
        tlsConfig: TLSConfig.fromJson(json['tlsConfig']),
        corsConfig: CORSConfig.fromJson(json['corsConfig']),
        cspConfig: CSPConfig.fromJson(json['cspConfig']),
        ipWhitelist: IPWhitelistConfig.fromJson(json['ipWhitelist']),
        securityHeaders: SecurityHeaders.fromJson(json['securityHeaders']),
        enableSecurityAuditing: json['enableSecurityAuditing'],
      );
}

// ===== ADDITIONAL ENUMS =====

enum KeyValidationMode { database, cache, external }

enum PolicyEffect { allow, deny }

enum CacheStrategy { none, memory, redis, hybrid }

enum EvictionPolicy { lru, lfu, ttl, random }

// ===== PLACEHOLDER CLASSES =====
// These would need full implementations in a real system

class Role {
  final String name;
  final List<String> permissions;

  Role({required this.name, required this.permissions});

  Map<String, dynamic> toJson() => {'name': name, 'permissions': permissions};
  factory Role.fromJson(Map<String, dynamic> json) => Role(
      name: json['name'], permissions: List<String>.from(json['permissions']));
}

class Permission {
  final String resource;
  final String action;

  Permission({required this.resource, required this.action});

  Map<String, dynamic> toJson() => {'resource': resource, 'action': action};
  factory Permission.fromJson(Map<String, dynamic> json) =>
      Permission(resource: json['resource'], action: json['action']);
}

class AttributeDefinition {
  final String name;
  final String type;

  AttributeDefinition({required this.name, required this.type});

  Map<String, dynamic> toJson() => {'name': name, 'type': type};
  factory AttributeDefinition.fromJson(Map<String, dynamic> json) =>
      AttributeDefinition(name: json['name'], type: json['type']);
}

class PolicyRule {
  final String condition;
  final String effect;

  PolicyRule({required this.condition, required this.effect});

  Map<String, dynamic> toJson() => {'condition': condition, 'effect': effect};
  factory PolicyRule.fromJson(Map<String, dynamic> json) =>
      PolicyRule(condition: json['condition'], effect: json['effect']);
}

class RequestTransform {
  final String type;
  final Map<String, dynamic> config;

  RequestTransform({required this.type, required this.config});

  Map<String, dynamic> toJson() => {'type': type, 'config': config};
  factory RequestTransform.fromJson(Map<String, dynamic> json) =>
      RequestTransform(type: json['type'], config: json['config']);
}

class ResponseTransform {
  final String type;
  final Map<String, dynamic> config;

  ResponseTransform({required this.type, required this.config});

  Map<String, dynamic> toJson() => {'type': type, 'config': config};
  factory ResponseTransform.fromJson(Map<String, dynamic> json) =>
      ResponseTransform(type: json['type'], config: json['config']);
}

class ValidationConfig {
  final bool enabled;
  final List<String> rules;

  ValidationConfig({required this.enabled, required this.rules});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'rules': rules};
  factory ValidationConfig.fromJson(Map<String, dynamic> json) =>
      ValidationConfig(
          enabled: json['enabled'], rules: List<String>.from(json['rules']));
}

class CompressionConfig {
  final bool enabled;
  final String algorithm;

  CompressionConfig({required this.enabled, required this.algorithm});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'algorithm': algorithm};
  factory CompressionConfig.fromJson(Map<String, dynamic> json) =>
      CompressionConfig(enabled: json['enabled'], algorithm: json['algorithm']);
}

class DataMapper {
  final String source;
  final String target;

  DataMapper({required this.source, required this.target});

  Map<String, dynamic> toJson() => {'source': source, 'target': target};
  factory DataMapper.fromJson(Map<String, dynamic> json) =>
      DataMapper(source: json['source'], target: json['target']);
}

class FormatConverter {
  final String inputFormat;
  final String outputFormat;

  FormatConverter({required this.inputFormat, required this.outputFormat});

  Map<String, dynamic> toJson() =>
      {'inputFormat': inputFormat, 'outputFormat': outputFormat};
  factory FormatConverter.fromJson(Map<String, dynamic> json) =>
      FormatConverter(
          inputFormat: json['inputFormat'], outputFormat: json['outputFormat']);
}

class ContentEnricher {
  final bool enabled;
  final List<String> enrichments;

  ContentEnricher({required this.enabled, required this.enrichments});

  Map<String, dynamic> toJson() =>
      {'enabled': enabled, 'enrichments': enrichments};
  factory ContentEnricher.fromJson(Map<String, dynamic> json) =>
      ContentEnricher(
          enabled: json['enabled'],
          enrichments: List<String>.from(json['enrichments']));
}

class SchemaRegistry {
  final String url;
  final Map<String, String> schemas;

  SchemaRegistry({required this.url, required this.schemas});

  Map<String, dynamic> toJson() => {'url': url, 'schemas': schemas};
  factory SchemaRegistry.fromJson(Map<String, dynamic> json) => SchemaRegistry(
      url: json['url'], schemas: Map<String, String>.from(json['schemas']));
}

class MetricsConfig {
  final bool enabled;
  final List<String> metrics;

  MetricsConfig({required this.enabled, required this.metrics});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'metrics': metrics};
  factory MetricsConfig.fromJson(Map<String, dynamic> json) => MetricsConfig(
      enabled: json['enabled'], metrics: List<String>.from(json['metrics']));
}

class LoggingConfig {
  final String level;
  final String format;

  LoggingConfig({required this.level, required this.format});

  Map<String, dynamic> toJson() => {'level': level, 'format': format};
  factory LoggingConfig.fromJson(Map<String, dynamic> json) =>
      LoggingConfig(level: json['level'], format: json['format']);
}

class TracingConfig {
  final bool enabled;
  final String tracer;

  TracingConfig({required this.enabled, required this.tracer});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'tracer': tracer};
  factory TracingConfig.fromJson(Map<String, dynamic> json) =>
      TracingConfig(enabled: json['enabled'], tracer: json['tracer']);
}

class AlertingConfig {
  final bool enabled;
  final List<String> channels;

  AlertingConfig({required this.enabled, required this.channels});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'channels': channels};
  factory AlertingConfig.fromJson(Map<String, dynamic> json) => AlertingConfig(
      enabled: json['enabled'], channels: List<String>.from(json['channels']));
}

class CacheRule {
  final String pattern;
  final Duration ttl;

  CacheRule({required this.pattern, required this.ttl});

  Map<String, dynamic> toJson() => {'pattern': pattern, 'ttl': ttl.inSeconds};
  factory CacheRule.fromJson(Map<String, dynamic> json) =>
      CacheRule(pattern: json['pattern'], ttl: Duration(seconds: json['ttl']));
}

class TLSConfig {
  final bool enabled;
  final String version;

  TLSConfig({required this.enabled, required this.version});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'version': version};
  factory TLSConfig.fromJson(Map<String, dynamic> json) =>
      TLSConfig(enabled: json['enabled'], version: json['version']);
}

class CORSConfig {
  final bool enabled;
  final List<String> allowedOrigins;

  CORSConfig({required this.enabled, required this.allowedOrigins});

  Map<String, dynamic> toJson() =>
      {'enabled': enabled, 'allowedOrigins': allowedOrigins};
  factory CORSConfig.fromJson(Map<String, dynamic> json) => CORSConfig(
      enabled: json['enabled'],
      allowedOrigins: List<String>.from(json['allowedOrigins']));
}

class CSPConfig {
  final bool enabled;
  final String policy;

  CSPConfig({required this.enabled, required this.policy});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'policy': policy};
  factory CSPConfig.fromJson(Map<String, dynamic> json) =>
      CSPConfig(enabled: json['enabled'], policy: json['policy']);
}

class IPWhitelistConfig {
  final bool enabled;
  final List<String> allowedIPs;

  IPWhitelistConfig({required this.enabled, required this.allowedIPs});

  Map<String, dynamic> toJson() =>
      {'enabled': enabled, 'allowedIPs': allowedIPs};
  factory IPWhitelistConfig.fromJson(Map<String, dynamic> json) =>
      IPWhitelistConfig(
          enabled: json['enabled'],
          allowedIPs: List<String>.from(json['allowedIPs']));
}

class SecurityHeaders {
  final bool enabled;
  final Map<String, String> headers;

  SecurityHeaders({required this.enabled, required this.headers});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'headers': headers};
  factory SecurityHeaders.fromJson(Map<String, dynamic> json) =>
      SecurityHeaders(
          enabled: json['enabled'],
          headers: Map<String, String>.from(json['headers']));
}

class WebhookEndpoint {
  final String url;
  final List<String> events;

  WebhookEndpoint({required this.url, required this.events});

  Map<String, dynamic> toJson() => {'url': url, 'events': events};
  factory WebhookEndpoint.fromJson(Map<String, dynamic> json) =>
      WebhookEndpoint(
          url: json['url'], events: List<String>.from(json['events']));
}

class WebhookSecurity {
  final bool enabled;
  final String secret;

  WebhookSecurity({required this.enabled, required this.secret});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'secret': secret};
  factory WebhookSecurity.fromJson(Map<String, dynamic> json) =>
      WebhookSecurity(enabled: json['enabled'], secret: json['secret']);
}

class RetryPolicy {
  final int maxRetries;
  final Duration backoff;

  RetryPolicy({required this.maxRetries, required this.backoff});

  Map<String, dynamic> toJson() =>
      {'maxRetries': maxRetries, 'backoff': backoff.inMilliseconds};
  factory RetryPolicy.fromJson(Map<String, dynamic> json) => RetryPolicy(
      maxRetries: json['maxRetries'],
      backoff: Duration(milliseconds: json['backoff']));
}

class RetryOptions {
  final int maxRetries;
  final Duration baseDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  RetryOptions({
    required this.maxRetries,
    required this.baseDelay,
    required this.backoffMultiplier,
    required this.maxDelay,
  });

  Map<String, dynamic> toJson() => {
        'maxRetries': maxRetries,
        'baseDelay': baseDelay.inMilliseconds,
        'backoffMultiplier': backoffMultiplier,
        'maxDelay': maxDelay.inMilliseconds,
      };

  factory RetryOptions.fromJson(Map<String, dynamic> json) => RetryOptions(
        maxRetries: json['maxRetries'],
        baseDelay: Duration(milliseconds: json['baseDelay']),
        backoffMultiplier: json['backoffMultiplier'].toDouble(),
        maxDelay: Duration(milliseconds: json['maxDelay']),
      );
}

class EventFilter {
  final String type;
  final Map<String, dynamic> conditions;

  EventFilter({required this.type, required this.conditions});

  Map<String, dynamic> toJson() => {'type': type, 'conditions': conditions};
  factory EventFilter.fromJson(Map<String, dynamic> json) =>
      EventFilter(type: json['type'], conditions: json['conditions']);
}

class SyncMapping {
  final String sourceField;
  final String targetField;
  final String? transformation;

  SyncMapping(
      {required this.sourceField,
      required this.targetField,
      this.transformation});

  Map<String, dynamic> toJson() => {
        'sourceField': sourceField,
        'targetField': targetField,
        'transformation': transformation
      };
  factory SyncMapping.fromJson(Map<String, dynamic> json) => SyncMapping(
      sourceField: json['sourceField'],
      targetField: json['targetField'],
      transformation: json['transformation']);
}

class DataTransformation {
  final bool enabled;
  final List<String> rules;

  DataTransformation({required this.enabled, required this.rules});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'rules': rules};
  factory DataTransformation.fromJson(Map<String, dynamic> json) =>
      DataTransformation(
          enabled: json['enabled'], rules: List<String>.from(json['rules']));
}
