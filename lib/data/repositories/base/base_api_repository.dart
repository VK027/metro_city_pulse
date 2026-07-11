import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class BaseApiRepository {
  @protected
  Future<void> callApi<T, H>({
    required Future<HttpResponse> Function() request,
  }) async {

  }
}
