import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../models/catalog_search_filters.dart';
import '../models/resource_item.dart';
import '../repositories/catalog_repository.dart';
import 'catalog_state.dart';

class CatalogController extends StateNotifier<CatalogState> {
  CatalogController({
    required CatalogRepository catalogRepository,
  })  : _catalogRepository = catalogRepository,
        super(const CatalogState());

  final CatalogRepository _catalogRepository;

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );
    try {
      final cached = await _catalogRepository.getCatalog(forceRefresh: false);
      state = state.copyWith(
        index: cached,
        isLoading: false,
      );
      _recomputeDerived(resetError: true);
      if (cached.resources.isEmpty) {
        state = state.copyWith(
          error: const AppException(
            type: AppErrorType.emptyData,
            message: 'No PDF files were found in the configured Drive folder.',
          ),
        );
      }
    } on AppException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: const AppException(
          type: AppErrorType.unknown,
          message: 'Failed to load catalog.',
        ),
      );
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) {
      return;
    }
    state = state.copyWith(
      isRefreshing: true,
      error: null,
    );
    try {
      final index = await _catalogRepository.refreshCatalog();
      state = state.copyWith(
        index: index,
        isRefreshing: false,
      );
      _recomputeDerived(resetError: true);
      if (index.resources.isEmpty) {
        state = state.copyWith(
          error: const AppException(
            type: AppErrorType.emptyData,
            message: 'No PDF files were found in the configured Drive folder.',
          ),
        );
      }
    } on AppException catch (error) {
      state = state.copyWith(
        isRefreshing: false,
        error: error,
      );
      _recomputeDerived();
    } catch (_) {
      state = state.copyWith(
        isRefreshing: false,
        error: const AppException(
          type: AppErrorType.unknown,
          message: 'Failed to refresh catalog.',
        ),
      );
      _recomputeDerived();
    }
  }

  void setSearchQuery(String value) {
    state = state.copyWith(
      searchQuery: value,
      selectedCategories: <String>{},
    );
    _recomputeDerived();
  }

  void selectDepartment(String? department) {
    state = state.copyWith(
      selectedDepartment: department,
      selectedSemester: null,
      selectedSubject: null,
      selectedCategories: <String>{},
    );
    _recomputeDerived();
  }

  void selectSemester(String? semester) {
    state = state.copyWith(
      selectedSemester: semester,
      selectedSubject: null,
      selectedCategories: <String>{},
    );
    _recomputeDerived();
  }

  void selectSubject(String? subject) {
    state = state.copyWith(
      selectedSubject: subject,
      selectedCategories: <String>{},
    );
    _recomputeDerived();
  }

  void toggleCategory(String category) {
    final updated = <String>{...state.selectedCategories};
    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }
    state = state.copyWith(selectedCategories: updated);
    _recomputeDerived();
  }

  void clearFilters() {
    state = state.copyWith(
      selectedDepartment: null,
      selectedSemester: null,
      selectedSubject: null,
      selectedCategories: <String>{},
      searchQuery: '',
    );
    _recomputeDerived();
  }

  void _recomputeDerived({bool resetError = false}) {
    final index = state.index;
    if (index == null) {
      state = state.copyWith(
        departments: const <String>[],
        semesters: const <String>[],
        subjects: const <String>[],
        categories: const <String>[],
        visibleResources: const <ResourceItem>[],
        error: resetError ? null : state.error,
      );
      return;
    }

    final resources = index.resources;
    final departments =
        _distinctSorted(resources.map((item) => item.department));

    var selectedDepartment = state.selectedDepartment;
    if (selectedDepartment != null &&
        !departments.contains(selectedDepartment)) {
      selectedDepartment = null;
    }

    final departmentResources = selectedDepartment == null
        ? <ResourceItem>[]
        : resources
            .where((item) => item.department == selectedDepartment)
            .toList();

    final semesters = selectedDepartment == null
        ? const <String>[]
        : _distinctSorted(departmentResources.map((item) => item.semester));

    var selectedSemester = state.selectedSemester;
    if (selectedSemester != null && !semesters.contains(selectedSemester)) {
      selectedSemester = null;
    }

    final semesterResources =
        selectedDepartment == null || selectedSemester == null
            ? <ResourceItem>[]
            : departmentResources
                .where((item) => item.semester == selectedSemester)
                .toList();

    final subjects = selectedDepartment == null || selectedSemester == null
        ? const <String>[]
        : _distinctSorted(semesterResources.map((item) => item.subject));

    var selectedSubject = state.selectedSubject;
    if (selectedSubject != null && !subjects.contains(selectedSubject)) {
      selectedSubject = null;
    }

    final subjectResources = selectedDepartment == null ||
            selectedSemester == null ||
            selectedSubject == null
        ? <ResourceItem>[]
        : semesterResources
            .where((item) => item.subject == selectedSubject)
            .toList();

    final categories = selectedDepartment == null ||
            selectedSemester == null ||
            selectedSubject == null
        ? const <String>[]
        : _distinctSorted(subjectResources.map((item) => item.category));

    var selectedCategories = <String>{...state.selectedCategories};
    selectedCategories.removeWhere((item) => !categories.contains(item));

    final query = state.searchQuery.trim();
    final shouldRequireDrilldown = query.isEmpty;
    final isHierarchyComplete = selectedDepartment != null &&
        selectedSemester != null &&
        selectedSubject != null;

    final filters = CatalogSearchFilters(
      department: selectedDepartment,
      semester: selectedSemester,
      subject: selectedSubject,
      categories: selectedCategories,
    );

    final visibleResources = shouldRequireDrilldown && !isHierarchyComplete
        ? const <ResourceItem>[]
        : _catalogRepository.search(
            index: index,
            query: query,
            filters: filters,
          );

    state = state.copyWith(
      selectedDepartment: selectedDepartment,
      selectedSemester: selectedSemester,
      selectedSubject: selectedSubject,
      selectedCategories: selectedCategories,
      departments: departments,
      semesters: semesters,
      subjects: subjects,
      categories: categories,
      visibleResources: visibleResources,
      error: resetError ? null : state.error,
    );
  }

  List<String> _distinctSorted(Iterable<String> values) {
    final list = values.toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }
}
