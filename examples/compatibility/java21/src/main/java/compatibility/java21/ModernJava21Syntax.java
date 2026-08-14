package compatibility.java21;

public final class ModernJava21Syntax {

    public sealed interface Shape permits Circle, Rectangle {
    }

    public record Circle(double radius) implements Shape {
    }

    public record Rectangle(double width, double height) implements Shape {
    }

    public double area(Shape shape) {
        return switch (shape) {
            case Circle(double radius) -> Math.PI * radius * radius;
            case Rectangle(double width, double height) -> width * height;
        };
    }

    public String normalize(Object value) {
        return switch (value) {
            case null -> "null";
            case String text when !text.isBlank() -> text.strip();
            case String text -> "blank:" + text.length();
            default -> value.toString();
        };
    }
}
