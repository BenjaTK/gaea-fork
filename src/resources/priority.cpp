#include "priority.h"

#include "godot_cpp/classes/wrapped.hpp"

using namespace godot;

void GaeaPriority::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_priority_level"), &GaeaPriority::get_priority_level);

    GDVIRTUAL_BIND(_get_priority_level);
}

float GaeaPriority::get_priority_level() const {
    ERR_FAIL_COND_V(!GDVIRTUAL_IS_OVERRIDDEN(_get_priority_level), 0.0);
    float level;
    GDVIRTUAL_CALL(_get_priority_level, level);
    return level;
}

void GaeaBasicPriority::_bind_methods() {
    ClassDB::bind_static_method("GaeaBasicPriority", D_METHOD("create", "level"), &GaeaBasicPriority::create);

    ClassDB::bind_method(D_METHOD("set_level", "level"), &GaeaBasicPriority::set_level);
    ClassDB::bind_method(D_METHOD("get_level"), &GaeaBasicPriority::get_level);

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "level"), "set_level", "get_level");
}

Ref<GaeaBasicPriority> GaeaBasicPriority::create(const float& p_level) {
    Ref<GaeaBasicPriority> ret;
    ret.instantiate();
    ret->set_level(p_level);
    return ret;
}

void GaeaGenerationPriority::_bind_methods() {
    ClassDB::bind_static_method("GaeaGenerationPriority", D_METHOD("create", "origin", "area"), &GaeaGenerationPriority::create);

    ClassDB::bind_method(D_METHOD("set_origin", "origin"), &GaeaGenerationPriority::set_origin);
    ClassDB::bind_method(D_METHOD("get_origin"), &GaeaGenerationPriority::get_origin);
    ClassDB::bind_method(D_METHOD("set_area", "area"), &GaeaGenerationPriority::set_area);
    ClassDB::bind_method(D_METHOD("get_area"), &GaeaGenerationPriority::get_area);

    ADD_PROPERTY(PropertyInfo(Variant::VECTOR3I, "origin"), "set_origin", "get_origin");
    ADD_PROPERTY(PropertyInfo(Variant::AABB, "area"), "set_area", "get_area");
}

Ref<GaeaGenerationPriority> GaeaGenerationPriority::create(const Vector3i& p_origin, const AABB& p_area) {
    Ref<GaeaGenerationPriority> ret;
    ret.instantiate();
    ret->set_origin(p_origin);
    ret->set_area(p_area);
    return ret;
}

void GaeaGenerationPriority::set_origin(const Vector3i& p_origin) {
    origin = p_origin;
}

Vector3i GaeaGenerationPriority::get_origin() const {
    return origin;
}

void GaeaGenerationPriority::set_area(const AABB& p_area) {
    area = p_area;
}

AABB GaeaGenerationPriority::get_area() const {
    return area;
}

float GaeaGenerationPriority::get_priority_level() const {
    Vector3 position = area.get_position() / area.get_size();
    return origin.distance_squared_to(position);
}
