import 'package:imrpo/core/helpers/association_scope_helper.dart';
import 'package:imrpo/core/services/association_context.dart';
import 'package:imrpo/core/services/service_locator.dart';

/// Shared association scoping for Supabase financial datasources.
mixin AssociationDatasourceMixin {
  bool get useAssociationScope {
    final ctx = getIt<AssociationContext>();
    return ctx.isAvailable &&
        ctx.isLoaded &&
        ctx.activeAssociationId != null &&
        ctx.activeAssociationId!.isNotEmpty;
  }

  Map<String, dynamic> scopedFinancialRow(Map<String, dynamic> row) {
    if (!useAssociationScope) return row;
    return {...row, 'association_id': requireAssociationId()};
  }

  T scopeFinancialQuery<T>(T query) {
    if (!useAssociationScope) return query;
    return (query as dynamic).eq('association_id', requireAssociationId()) as T;
  }
}
