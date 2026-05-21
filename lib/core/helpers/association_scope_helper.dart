import 'package:imrpo/core/services/association_context.dart';
import 'package:imrpo/core/services/service_locator.dart';

/// Active association for Supabase financial rows.
String requireAssociationId() => getIt<AssociationContext>().requireActiveId();
