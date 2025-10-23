import 'package:flutter/foundation.dart';

const String productionUrl = 'https://applog-pd.srv812681.hstgr.cloud/';
const String developmentUrl = 'https://applog.srv812681.hstgr.cloud/';

const String baseUrl = kDebugMode ? developmentUrl : productionUrl;
