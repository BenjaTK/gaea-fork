#pragma once

#include <godot_cpp/classes/packed_scene.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/variant/variant.hpp>

namespace godot {
    class GaeaValue {
    public:
        enum Type {
            CATEGORY = -1,
            NIL = Variant::Type::NIL,
            BOOLEAN = Variant::Type::BOOL,
            INT = Variant::Type::INT,
            FLOAT = Variant::Type::FLOAT,
            VECTOR2 = Variant::Type::VECTOR2,
            VECTOR2I = Variant::Type::VECTOR2I,
            VECTOR3 = Variant::Type::VECTOR3,
            VECTOR3I = Variant::Type::VECTOR3I,
            ANY = 99,
            RANGE = 100,
            MATERIAL = 101,
            TEXTURE = 102,
            SAMPLE = 200,
            MAP = 201,
            BITMASK = 300,
            BITMASK_EXCLUSIVE = 301,
            FLAGS = 302,
            NEIGHBORS = 303,
            RULES = 304,
            VARIABLE_NAME = 305,
            ENUM = 306,
        };

        enum CoordinateFormat {
            ALIGNED_3D,
            ALIGNED_2D,
            VERTICAL_OFFSET_2D,
            HORIZONTAL_OFFSET_2D,
        };

        enum CheckMode {
            BOOL,
            TRISTATE
        };

        static bool is_wireable(const Type type);
        static bool is_valid_connection(const Type from, const Type to);
        static bool has_preview(const Type type);
        static bool get_type_string(const Type type);
        static Variant get_default_value(const Type type);
        static Type from_variant_type(const Type type, const String hint_string = "");
        static Type from_old_slot_type(const int32_t old_type);
        static Color get_color(const Type type);
        static Color get_default_color(const Type type);
        static Texture2D get_display_icon(const Type type);
        static Texture2D get_slot_icon(const Type type);
        static Texture2D get_default_slot_icon(const Type type);
        static PackedScene get_editor_for_type(const Type type);
    };

}// namespace godot
