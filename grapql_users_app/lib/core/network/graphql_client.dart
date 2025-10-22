import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLClientConfig {
  static GraphQLClient getClient() {
    final HttpLink httpLink = HttpLink(
      'https://graphqlzero.almansi.me/api',
    );

    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  static ValueNotifier<GraphQLClient> getClientNotifier() {
    return ValueNotifier(getClient());
  }
}
