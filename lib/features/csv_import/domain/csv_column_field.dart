enum CsvColumnField {
  skip,
  title,
  amount,
  date,
  category,
  type,
  paidFrom,
}

extension CsvColumnFieldX on CsvColumnField {
  bool get isRequiredMapping =>
      this == CsvColumnField.title ||
      this == CsvColumnField.amount ||
      this == CsvColumnField.type;
}
