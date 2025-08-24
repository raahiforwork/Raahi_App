import 'package:flutter/cupertino.dart';

import '../../utils/constants/sizes.dart';

class RSpacingStyle {
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: RSizes.appBarHeight,
    left: RSizes.defaultSpace,
    bottom: RSizes.defaultSpace,
    right: RSizes.defaultSpace,
  );
}
