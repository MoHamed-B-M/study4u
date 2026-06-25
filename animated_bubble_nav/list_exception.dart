class BubbleExceptions {
  static const String listSizesException =
      "Configuration Error: The number of screens does not match the number of bottom navigation menuItems. \n"
      "Each navigation item must have a corresponding screen widget. Please ensure both lists are of the same length.";

  static String initialIndexStart =
      "Invalid initialIndex! Minimum value for initialIndex must be set to 0.";

  static String initialIndexLimit(int limit) =>
      "Invalid initialIndex! Value provided for the initial index exceeds the screens length that is $limit";
}
