abstract class Mapper<T> {
  T fromMap(Map<String, Object?> map);
  Map<String, Object?> toMap(T entity);
}
