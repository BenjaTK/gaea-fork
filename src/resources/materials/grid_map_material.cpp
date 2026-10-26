#include "grid_map_material.h"

#include "godot_cpp/classes/global_constants.hpp"
#include "godot_cpp/core/property_info.hpp"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GridMapGaeaMaterial::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_item_idx", "value"), &GridMapGaeaMaterial::set_item_idx);
    ClassDB::bind_method(D_METHOD("get_item_idx"), &GridMapGaeaMaterial::get_item_idx);
    ClassDB::bind_method(D_METHOD("set_orientation", "value"), &GridMapGaeaMaterial::set_orientation);
    ClassDB::bind_method(D_METHOD("get_orientation"), &GridMapGaeaMaterial::get_orientation);

    ADD_PROPERTY(PropertyInfo(Variant::INT, "item_idx"), "set_item_idx", "get_item_idx");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "orientation", PROPERTY_HINT_RANGE, "0,23,1"), "set_orientation", "get_orientation");
}

void GridMapGaeaMaterial::set_item_idx(const int value) {
    item_idx = Math::max(-1, value);
}

int GridMapGaeaMaterial::get_item_idx() const {
    return item_idx;
}

void GridMapGaeaMaterial::set_orientation(const int value) {
    orientation = Math::clamp(value, 0, 23);
}

int GridMapGaeaMaterial::get_orientation() const {
    return orientation;
}
