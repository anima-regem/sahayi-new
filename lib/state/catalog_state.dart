import '../core/errors/app_exception.dart';
import '../models/catalog_index.dart';
import '../models/resource_item.dart';

class CatalogState {
  const CatalogState({
    this.index,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.searchQuery = '',
    this.selectedDepartment,
    this.selectedSemester,
    this.selectedSubject,
    this.selectedCategories = const <String>{},
    this.departments = const <String>[],
    this.semesters = const <String>[],
    this.subjects = const <String>[],
    this.categories = const <String>[],
    this.visibleResources = const <ResourceItem>[],
  });

  final CatalogIndex? index;
  final bool isLoading;
  final bool isRefreshing;
  final AppException? error;
  final String searchQuery;
  final String? selectedDepartment;
  final String? selectedSemester;
  final String? selectedSubject;
  final Set<String> selectedCategories;
  final List<String> departments;
  final List<String> semesters;
  final List<String> subjects;
  final List<String> categories;
  final List<ResourceItem> visibleResources;

  bool get hasData => index != null && index!.resources.isNotEmpty;

  CatalogState copyWith({
    CatalogIndex? index,
    bool? isLoading,
    bool? isRefreshing,
    Object? error = _sentinel,
    String? searchQuery,
    Object? selectedDepartment = _sentinel,
    Object? selectedSemester = _sentinel,
    Object? selectedSubject = _sentinel,
    Set<String>? selectedCategories,
    List<String>? departments,
    List<String>? semesters,
    List<String>? subjects,
    List<String>? categories,
    List<ResourceItem>? visibleResources,
  }) {
    return CatalogState(
      index: index ?? this.index,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error == _sentinel ? this.error : error as AppException?,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDepartment: selectedDepartment == _sentinel
          ? this.selectedDepartment
          : selectedDepartment as String?,
      selectedSemester: selectedSemester == _sentinel
          ? this.selectedSemester
          : selectedSemester as String?,
      selectedSubject: selectedSubject == _sentinel
          ? this.selectedSubject
          : selectedSubject as String?,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      departments: departments ?? this.departments,
      semesters: semesters ?? this.semesters,
      subjects: subjects ?? this.subjects,
      categories: categories ?? this.categories,
      visibleResources: visibleResources ?? this.visibleResources,
    );
  }
}

const _sentinel = Object();
