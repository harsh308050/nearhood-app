import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/business/models/business_models.dart';

class BusinessState {
  final ApiCallState checkStatus;
  final ApiCallState registerStatus;
  final ApiCallState logoUploadStatus;
  final ApiCallState coverUploadStatus;
  final ApiCallState fetchProfileStatus;
  final bool hasBusinessProfile;
  final String? logoUrl;
  final String? coverUrl;
  final String? errorMessage;
  final BusinessProfile? businessProfile;

  // Dashboard
  final ApiCallState dashboardStatus;
  final BusinessDashboard? dashboard;

  // Listings
  final ApiCallState listingsStatus;
  final List<BusinessListing> products;
  final List<BusinessListing> services;

  // Boost
  final ApiCallState boostStatus;
  final List<Map<String, dynamic>> activeBoosts;

  // Phone Plan
  final ApiCallState phonePlanStatus;
  final bool hasPhonePlan;

  // Listings Categories
  final ApiCallState categoriesStatus;
  final List<ListingCategory> productCategories;
  final List<ListingCategory> serviceCategories;

  // Business Profile Categories
  final ApiCallState businessCategoriesStatus;
  final List<BusinessCategory> productBusinessCategories;
  final List<BusinessCategory> serviceProvidingBusinessCategories;

  const BusinessState({
    this.checkStatus = ApiCallState.none,
    this.registerStatus = ApiCallState.none,
    this.logoUploadStatus = ApiCallState.none,
    this.coverUploadStatus = ApiCallState.none,
    this.fetchProfileStatus = ApiCallState.none,
    this.hasBusinessProfile = false,
    this.logoUrl,
    this.coverUrl,
    this.errorMessage,
    this.businessProfile,
    this.dashboardStatus = ApiCallState.none,
    this.dashboard,
    this.listingsStatus = ApiCallState.none,
    this.products = const [],
    this.services = const [],
    this.boostStatus = ApiCallState.none,
    this.activeBoosts = const [],
    this.phonePlanStatus = ApiCallState.none,
    this.hasPhonePlan = false,
    this.categoriesStatus = ApiCallState.none,
    this.productCategories = const [],
    this.serviceCategories = const [],
    this.businessCategoriesStatus = ApiCallState.none,
    this.productBusinessCategories = const [],
    this.serviceProvidingBusinessCategories = const [],
  });

  BusinessState copyWith({
    ApiCallState? checkStatus,
    ApiCallState? registerStatus,
    ApiCallState? logoUploadStatus,
    ApiCallState? coverUploadStatus,
    ApiCallState? fetchProfileStatus,
    bool? hasBusinessProfile,
    String? logoUrl,
    String? coverUrl,
    String? errorMessage,
    BusinessProfile? businessProfile,
    bool clearError = false,
    bool clearLogo = false,
    bool clearCover = false,
    bool clearProfile = false,
    ApiCallState? dashboardStatus,
    BusinessDashboard? dashboard,
    bool clearDashboard = false,
    ApiCallState? listingsStatus,
    List<BusinessListing>? products,
    List<BusinessListing>? services,
    bool clearProducts = false,
    bool clearServices = false,
    ApiCallState? boostStatus,
    List<Map<String, dynamic>>? activeBoosts,
    bool clearBoosts = false,
    ApiCallState? phonePlanStatus,
    bool? hasPhonePlan,
    ApiCallState? categoriesStatus,
    List<ListingCategory>? productCategories,
    List<ListingCategory>? serviceCategories,
    ApiCallState? businessCategoriesStatus,
    List<BusinessCategory>? productBusinessCategories,
    List<BusinessCategory>? serviceProvidingBusinessCategories,
  }) {
    return BusinessState(
      checkStatus: checkStatus ?? this.checkStatus,
      registerStatus: registerStatus ?? this.registerStatus,
      logoUploadStatus: logoUploadStatus ?? this.logoUploadStatus,
      coverUploadStatus: coverUploadStatus ?? this.coverUploadStatus,
      fetchProfileStatus: fetchProfileStatus ?? this.fetchProfileStatus,
      hasBusinessProfile: hasBusinessProfile ?? this.hasBusinessProfile,
      logoUrl: clearLogo ? null : (logoUrl ?? this.logoUrl),
      coverUrl: clearCover ? null : (coverUrl ?? this.coverUrl),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      businessProfile: clearProfile ? null : (businessProfile ?? this.businessProfile),
      dashboardStatus: dashboardStatus ?? this.dashboardStatus,
      dashboard: clearDashboard ? null : (dashboard ?? this.dashboard),
      listingsStatus: listingsStatus ?? this.listingsStatus,
      products: clearProducts ? [] : (products ?? this.products),
      services: clearServices ? [] : (services ?? this.services),
      boostStatus: boostStatus ?? this.boostStatus,
      activeBoosts: clearBoosts ? [] : (activeBoosts ?? this.activeBoosts),
      phonePlanStatus: phonePlanStatus ?? this.phonePlanStatus,
      hasPhonePlan: hasPhonePlan ?? this.hasPhonePlan,
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      productCategories: productCategories ?? this.productCategories,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      businessCategoriesStatus: businessCategoriesStatus ?? this.businessCategoriesStatus,
      productBusinessCategories: productBusinessCategories ?? this.productBusinessCategories,
      serviceProvidingBusinessCategories: serviceProvidingBusinessCategories ?? this.serviceProvidingBusinessCategories,
    );
  }
}
