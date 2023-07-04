import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

typedef TokenGetter = String? Function();

/// Wraps the root application with the `graphql_flutter` client.
/// We use the cache for all state management.
class ClientProvider extends StatelessWidget {
  ClientProvider({
    super.key,
    required this.child,
    required this.uri,
    required this.tokenGetter,
  }): client = ValueNotifier(buildClient(uri: uri, token: tokenGetter.value)) {
    tokenGetter.addListener(setClient);
  }

  final Widget child;
  final String uri;
  final ValueNotifier<String?> tokenGetter;
  final ValueNotifier<GraphQLClient> client;

  void setClient() {
    client.value = buildClient(uri: uri, token: tokenGetter.value);
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}

GraphQLClient buildClient({
  required String uri,
  required String? token,
}) {
  Link link = HttpLink(uri);

  if(token != null) {
    print("setting client, with valid token");
    final AuthLink authLink = AuthLink(
        getToken: () async {
          return "Bearer $token";
        }
    );
    link = authLink.concat(link);
  } else {
    print("client token null");
  }

  return GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
}