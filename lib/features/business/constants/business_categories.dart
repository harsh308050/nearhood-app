class BusinessCategories {
  BusinessCategories._();

  static const Map<String, List<String>> categories = {
    'Food & Dining': [
      'Restaurant / Dhaba',
      'Tiffin Service / Home Food',
      'Bakery / Sweets',
      'Juice / Tea / Coffee Shop',
      'Catering',
    ],
    'Home Services': [
      'Plumber',
      'Electrician',
      'Carpenter',
      'Painter',
      'AC / Appliance Repair',
      'Pest Control',
      'Cleaning Service',
      'Home Renovation',
    ],
    'Health & Wellness': [
      'Doctor / Clinic',
      'Dentist',
      'Physiotherapist',
      'Yoga / Fitness Trainer',
      'Pharmacy',
      'Pathology / Lab',
    ],
    'Beauty & Personal Care': [
      'Salon / Parlour',
      'Spa / Massage',
      'Tailor / Boutique',
    ],
    'Education & Tutoring': [
      'Home Tutor',
      'Coaching Classes',
      'Music / Dance Classes',
      'Drawing / Art Classes',
      'Computer Classes',
    ],
    'Retail & Shops': [
      'Grocery / Kirana',
      'Stationery',
      'Electronics',
      'Clothing / Fashion',
      'Hardware',
      'Medical Store',
    ],
    'Transport & Logistics': [
      'Auto / Cab Driver',
      'Packers and Movers',
      'Courier / Delivery',
    ],
    'Professional Services': [
      'Chartered Accountant',
      'Lawyer',
      'Real Estate Agent',
      'Insurance Agent',
      'Photographer / Videographer',
      'Graphic Designer',
    ],
    'Pets': [
      'Veterinary Clinic',
      'Pet Shop',
      'Dog Walker / Groomer',
    ],
    'Other': [],
  };

  static List<String> get allMainCategories => categories.keys.toList();

  static List<String> get allSubCategories =>
      categories.entries.expand((e) => e.value).toList();

  static List<String> subCategoriesOf(String mainCategory) =>
      categories[mainCategory] ?? [];

  static String? mainCategoryOf(String subCategory) {
    for (final entry in categories.entries) {
      if (entry.value.contains(subCategory)) return entry.key;
    }
    return null;
  }
}
