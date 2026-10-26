#include "tile_map_material.h"

#include "godot_cpp/classes/global_constants.hpp"
#include "godot_cpp/core/property_info.hpp"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void TileMapGaeaMaterial::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_type", "value"), &TileMapGaeaMaterial::set_type);
    ClassDB::bind_method(D_METHOD("get_type"), &TileMapGaeaMaterial::get_type);
    ClassDB::bind_method(D_METHOD("set_source_id", "value"), &TileMapGaeaMaterial::set_source_id);
    ClassDB::bind_method(D_METHOD("get_source_id"), &TileMapGaeaMaterial::get_source_id);
    ClassDB::bind_method(D_METHOD("set_alternative_tile", "value"), &TileMapGaeaMaterial::set_alternative_tile);
    ClassDB::bind_method(D_METHOD("get_alternative_tile"), &TileMapGaeaMaterial::get_alternative_tile);
    ClassDB::bind_method(D_METHOD("set_terrain_set", "value"), &TileMapGaeaMaterial::set_terrain_set);
    ClassDB::bind_method(D_METHOD("get_terrain_set"), &TileMapGaeaMaterial::get_terrain_set);
    ClassDB::bind_method(D_METHOD("set_terrain", "value"), &TileMapGaeaMaterial::set_terrain);
    ClassDB::bind_method(D_METHOD("get_terrain"), &TileMapGaeaMaterial::get_terrain);
    ClassDB::bind_method(D_METHOD("set_pattern_idx", "value"), &TileMapGaeaMaterial::set_pattern_idx);
    ClassDB::bind_method(D_METHOD("get_pattern_idx"), &TileMapGaeaMaterial::get_pattern_idx);
    ClassDB::bind_method(D_METHOD("set_atlas_coord", "value"), &TileMapGaeaMaterial::set_atlas_coord);
    ClassDB::bind_method(D_METHOD("get_atlas_coord"), &TileMapGaeaMaterial::get_atlas_coord);
    ClassDB::bind_method(D_METHOD("set_pattern_offset", "value"), &TileMapGaeaMaterial::set_pattern_offset);
    ClassDB::bind_method(D_METHOD("get_pattern_offset"), &TileMapGaeaMaterial::get_pattern_offset);

    ADD_PROPERTY(PropertyInfo(Variant::INT, "type", PROPERTY_HINT_ENUM, "Single Cell,Terrain,Pattern"), "set_type", "get_type");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "source_id"), "set_source_id", "get_source_id");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "alternative_tile"), "set_alternative_tile", "get_alternative_tile");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "terrain_set"), "set_terrain_set", "get_terrain_set");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "terrain"), "set_terrain", "get_terrain");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "pattern_idx"), "set_pattern_idx", "get_pattern_idx");
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2I, "atlas_coord"), "set_atlas_coord", "get_atlas_coord");
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2I, "pattern_offset"), "set_pattern_offset", "get_pattern_offset");

    BIND_ENUM_CONSTANT(TYPE_SINGLE_CELL);
    BIND_ENUM_CONSTANT(TYPE_TERRAIN);
    BIND_ENUM_CONSTANT(TYPE_PATTERN);
}

void TileMapGaeaMaterial::_validate_property(PropertyInfo& p_property) const {
    if (type != TYPE_SINGLE_CELL) {
        if (p_property.name == StringName("source_id") || p_property.name == StringName("atlas_coord") || p_property.name == StringName("alternative_tile")) {
            p_property.usage = PROPERTY_USAGE_NONE;
        }
    }

    if (type != TYPE_TERRAIN) {
        p_property.usage = p_property.name.begins_with("terrain") ? PROPERTY_USAGE_NONE : p_property.usage;
    }

    if (type != TYPE_PATTERN) {
        p_property.usage = p_property.name.begins_with("pattern") ? PROPERTY_USAGE_NONE : p_property.usage;
    }
}

void TileMapGaeaMaterial::set_type(const Type value) {
    type = value;
    notify_property_list_changed();
}

TileMapGaeaMaterial::Type TileMapGaeaMaterial::get_type() const {
    return type;
}

void TileMapGaeaMaterial::set_source_id(const int value) {
    source_id = Math::max(-1, value);
}

int TileMapGaeaMaterial::get_source_id() const {
    return source_id;
}

void TileMapGaeaMaterial::set_atlas_coord(const Vector2i value) {
    atlas_coord = value.max(Vector2i(-1, -1));
}

Vector2i TileMapGaeaMaterial::get_atlas_coord() const {
    return atlas_coord;
}

void TileMapGaeaMaterial::set_alternative_tile(const int value) {
    alternative_tile = Math::max(0, value);
}

int TileMapGaeaMaterial::get_alternative_tile() const {
    return alternative_tile;
}

void TileMapGaeaMaterial::set_terrain_set(const int value) {
    terrain_set = Math::max(0, value);
}

int TileMapGaeaMaterial::get_terrain_set() const {
    return terrain_set;
}

void TileMapGaeaMaterial::set_terrain(const int value) {
    terrain = Math::max(0, value);
}

int TileMapGaeaMaterial::get_terrain() const {
    return terrain;
}

void TileMapGaeaMaterial::set_pattern_idx(const int value) {
    pattern_idx = Math::max(0, value);
}

int TileMapGaeaMaterial::get_pattern_idx() const {
    return pattern_idx;
}

void TileMapGaeaMaterial::set_pattern_offset(const Vector2i value) {
    pattern_offset = value;
}

Vector2i TileMapGaeaMaterial::get_pattern_offset() const {
    return pattern_offset;
}

TileMapGaeaMaterial::TileMapGaeaMaterial() {
    type = TYPE_SINGLE_CELL;
    source_id = 0;
    atlas_coord = Vector2i(0, 0);
    alternative_tile = 0;
    terrain_set = 0;
    terrain = 0;
    pattern_idx = 0;
    pattern_offset = Vector2i(0, 0);
}
