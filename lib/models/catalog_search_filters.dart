class CatalogSearchFilters {
  const CatalogSearchFilters({
    this.department,
    this.semester,
    this.subject,
    this.categories = const <String>{},
  });

  final String? department;
  final String? semester;
  final String? subject;
  final Set<String> categories;
}
