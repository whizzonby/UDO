/// Everything collected across the onboarding flow. A plain mutable model
/// held by [OnboardingScreen]'s state and posted to `POST /onboarding` on
/// the final step.
class Collaborator {
  String name;
  String email;
  String role;
  Collaborator({this.name = '', this.email = '', this.role = 'Collaborator'});
}

class OnboardingAnswers {
  // Welcome
  String coupleName = '';
  String role = 'This is my wedding';

  // Decision-making
  String decisionStyle = 'We make decisions together';
  List<Collaborator> collaborators = [];

  // Planning structure
  String planningApproach = 'Self-managed';
  String plannerEmail = '';

  // Core event architecture
  String weddingType = 'Destination';
  String season = 'Summer';
  String dateStatus = 'Fixed';
  DateTime? weddingDate;
  String timeOfDay = 'Evening';
  List<String> eventStructure = ['Ceremony', 'Reception'];

  // Location & travel
  String country = '';
  String city = '';
  String venueStatus = 'Shortlisting';
  String guestTravel = 'Mixed';
  List<String> travelSupport = [];

  // Guest experience
  List<String> guestExperience = ['Children included', 'Accommodation required', 'Transport required', 'Meal selection required'];
  int guestCount = 100;

  // Budget
  double totalBudget = 25000;
  String budgetStructure = 'Flexible budget';
  String allocationPreference = 'Experience-focused';
  String funding = 'Self-funded';
  String budgetConfidence = 'Moderately defined';

  // Priorities
  List<String> priorities = ['Guest experience', 'Food & beverage quality'];

  // Food & dining
  String diningStyle = 'Formal plated';
  List<String> dietary = [];
  List<String> diningEnhancements = [];

  // Vendors
  List<String> coreVendors = ['Venue', 'Photographer', 'Catering'];
  List<String> expandedVendors = [];
  List<String> uniqueSuppliers = [];

  // Wedding party
  Map<String, bool> weddingParty = {
    'Maid of Honour': true,
    'Best Man': true,
    'Bridesmaids': true,
    'Groomsmen': true,
    'Ushers': false,
    'Flower Girl': false,
    'Page Boy': false,
    'Ring Bearer': false,
  };

  // Personal moments
  String speeches = 'Yes';
  List<String> whoSpeaking = [];
  String honouringLovedOnes = 'No';
  String tributeType = 'Memory table';
  String personalTouches = '';

  // Additional celebrations
  List<String> additionalEvents = [];
  String eventOrganizer = 'I am';

  // Cultural traditions module
  List<String> culturalCelebrationType = [];
  List<String> culturalTraditions = [];
  String otherTraditions = '';
  List<String> religiousStructure = [];
  String familyInvolvement = 'Mostly couple-led';
  String sharedPlanningAccess = 'Maybe later';
  List<String> guestHospitality = [];
  List<String> attirePlanning = [];
  String celebrationDuration = 'Full-day wedding';
  String celebrationAtmosphere = 'Intimate & emotional';
  String planningSupportStyle = 'Weekly guidance';

  // Honeymoon
  String planningHoneymoon = 'Yes';
  String honeymoonDestination = '';
  double honeymoonBudget = 5000;
  String honeymoonTiming = 'Immediate';

  // Insurance
  String insurance = 'Not sure';

  Map<String, dynamic> toJson() => {
        'couple_name': coupleName,
        'role': role,
        'decision_style': decisionStyle,
        'collaborators': collaborators.map((c) => {'name': c.name, 'email': c.email, 'role': c.role}).toList(),
        'planning_approach': planningApproach,
        'planner_email': plannerEmail.isEmpty ? null : plannerEmail,
        'wedding_type': weddingType,
        'season': season,
        'date_status': dateStatus,
        'event_date': weddingDate?.toIso8601String().split('T').first,
        'time_of_day': timeOfDay,
        'event_structure': eventStructure,
        'country': country,
        'city': city,
        'venue_status': venueStatus,
        'guest_travel': guestTravel,
        'travel_support': travelSupport,
        'guest_experience': guestExperience,
        'guest_count': guestCount,
        'total_budget': totalBudget,
        'budget_structure': budgetStructure,
        'allocation_preference': allocationPreference,
        'funding': funding,
        'budget_confidence': budgetConfidence,
        'priorities': priorities,
        'dining_style': diningStyle,
        'dietary': dietary,
        'dining_enhancements': diningEnhancements,
        'core_vendors': coreVendors,
        'expanded_vendors': expandedVendors,
        'unique_suppliers': uniqueSuppliers,
        'wedding_party': weddingParty,
        'speeches': speeches,
        'who_speaking': whoSpeaking,
        'honouring_loved_ones': honouringLovedOnes,
        'tribute_type': tributeType,
        'personal_touches': personalTouches,
        'additional_events': additionalEvents,
        'event_organizer': eventOrganizer,
        'cultural_celebration_type': culturalCelebrationType,
        'cultural_traditions': culturalTraditions,
        'other_traditions': otherTraditions,
        'religious_structure': religiousStructure,
        'family_involvement': familyInvolvement,
        'shared_planning_access': sharedPlanningAccess,
        'guest_hospitality': guestHospitality,
        'attire_planning': attirePlanning,
        'celebration_duration': celebrationDuration,
        'celebration_atmosphere': celebrationAtmosphere,
        'planning_support_style': planningSupportStyle,
        'planning_honeymoon': planningHoneymoon,
        'honeymoon_destination': honeymoonDestination.isEmpty ? null : honeymoonDestination,
        'honeymoon_budget': planningHoneymoon == 'Yes' ? honeymoonBudget : null,
        'honeymoon_timing': honeymoonTiming,
        'insurance': insurance,
      };

  /// Toggle helpers used by list-based steps.
  void toggle(List<String> list, String value, {int? max}) {
    if (list.contains(value)) {
      list.remove(value);
    } else if (max == null || list.length < max) {
      list.add(value);
    }
  }
}
