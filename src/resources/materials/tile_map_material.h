#pragma once

#include "material.h"

#include <godot_cpp/classes/resource.hpp>

namespace godot {
    class TileMapGaeaMaterial : public GaeaMaterial {
        GDCLASS(TileMapGaeaMaterial, GaeaMaterial)

    public:
        enum Type {
            TYPE_SINGLE_CELL,
            TYPE_TERRAIN,
            TYPE_PATTERN
        };

    private:
        Type type;
        int source_id;
        Vector2i atlas_coord;
        int alternative_tile;
        int terrain_set;
        int terrain;
        int pattern_idx;
        Vector2i pattern_offset;

    protected:
        void _validate_property(PropertyInfo& p_property) const;
        static void _bind_methods();

    public:
        void set_type(const Type value);
        Type get_type() const;

        void set_source_id(const int value);
        int get_source_id() const;

        void set_atlas_coord(const Vector2i value);
        Vector2i get_atlas_coord() const;

        void set_alternative_tile(const int value);
        int get_alternative_tile() const;

        void set_terrain_set(const int value);
        int get_terrain_set() const;

        void set_terrain(const int value);
        int get_terrain() const;

        void set_pattern_idx(const int value);
        int get_pattern_idx() const;

        void set_pattern_offset(const Vector2i value);
        Vector2i get_pattern_offset() const;

        virtual bool is_sampled() const override { return false; }

        virtual bool is_data() const override { return true; }

        TileMapGaeaMaterial();
    };
}// namespace godot

VARIANT_ENUM_CAST(TileMapGaeaMaterial::Type);
