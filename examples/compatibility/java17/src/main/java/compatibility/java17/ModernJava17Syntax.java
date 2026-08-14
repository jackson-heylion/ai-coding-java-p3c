package compatibility.java17;

public final class ModernJava17Syntax {

    public sealed interface Shape permits Circle, Rectangle {
    }

    public record Circle(double radius) implements Shape {
    }

    public record Rectangle(double width, double height) implements Shape {
    }

    public enum Kind {
        CIRCLE,
        RECTANGLE
    }

    public String describe(Shape shape) {
        if (shape instanceof Circle circle) {
            return """
                    circle:%s
                    """.formatted(circle.radius()).trim();
        }

        Rectangle rectangle = (Rectangle) shape;
        return "rectangle:" + rectangle.width() + "x" + rectangle.height();
    }

    public int code(Kind kind) {
        return switch (kind) {
            case CIRCLE -> 1;
            case RECTANGLE -> 2;
        };
    }
}
