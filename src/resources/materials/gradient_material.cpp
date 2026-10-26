#include "gradient_material.h"

#include "godot_cpp/classes/global_constants.hpp"
#include "godot_cpp/classes/gradient.hpp"
#include "godot_cpp/core/error_macros.hpp"
#include "godot_cpp/core/object.hpp"
#include "godot_cpp/core/property_info.hpp"

#include <sys/types.h>

#include <cstdint>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GradientGaeaMaterial::_bind_methods() {
    ClassDB::bind_method(D_METHOD("add_point", "offset", "material"), &GradientGaeaMaterial::add_point);
    ClassDB::bind_method(D_METHOD("remove_point", "point"), &GradientGaeaMaterial::remove_point);

    ClassDB::bind_method(D_METHOD("set_offset", "point", "offset"), &GradientGaeaMaterial::set_offset);
    ClassDB::bind_method(D_METHOD("get_offset", "point"), &GradientGaeaMaterial::get_offset);

    ClassDB::bind_method(D_METHOD("set_material", "point", "material"), &GradientGaeaMaterial::set_material);
    ClassDB::bind_method(D_METHOD("get_material", "point"), &GradientGaeaMaterial::get_material);

    ClassDB::bind_method(D_METHOD("sample", "offset"), &GradientGaeaMaterial::get_material_at_offset);
    ClassDB::bind_method(D_METHOD("get_point_count"), &GradientGaeaMaterial::get_point_count);

    ClassDB::bind_method(D_METHOD("set_offsets", "offsets"), &GradientGaeaMaterial::set_offsets);
    ClassDB::bind_method(D_METHOD("get_offsets"), &GradientGaeaMaterial::get_offsets);
    ClassDB::bind_method(D_METHOD("set_materials", "materials"), &GradientGaeaMaterial::set_materials);
    ClassDB::bind_method(D_METHOD("get_materials"), &GradientGaeaMaterial::get_materials);

    ADD_PROPERTY(PropertyInfo(Variant::PACKED_FLOAT32_ARRAY, "offsets"), "set_offsets", "get_offsets");
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "materials", PROPERTY_HINT_ARRAY_TYPE, "GaeaMaterial"), "set_materials", "get_materials");
}

PackedFloat32Array GradientGaeaMaterial::get_offsets() const {
    PackedFloat32Array offsets;
    offsets.resize(points.size());
    for (uint32_t i = 0; i < points.size(); i++) {
        offsets[i] = points[i].offset;
    }
    return offsets;
}

TypedArray<Ref<GaeaMaterial>> GradientGaeaMaterial::get_materials() const {
    TypedArray<Ref<GaeaMaterial>> materials;
    materials.resize(points.size());
    for (uint32_t i = 0; i < points.size(); i++) {
        materials[i] = points[i].material;
    }
    return materials;
}

void GradientGaeaMaterial::set_offsets(const PackedFloat32Array& p_offsets) {
    if (points.size() != p_offsets.size()) { return; }

    for (uint32_t i = 0; i < points.size(); i++) {
        points[i].offset = p_offsets[i];
    }
    is_sorted = false;
    emit_changed();
}

void GradientGaeaMaterial::set_materials(const TypedArray<Ref<GaeaMaterial>>& p_materials) {
    if (points.size() < p_materials.size()) { is_sorted = false; }
    points.resize(p_materials.size());
    for (uint32_t i = 0; i < points.size(); i++) {
        points[i].material = p_materials[i];
    }
    emit_changed();
}

void GradientGaeaMaterial::add_point(float p_offset, const Ref<GaeaMaterial>& p_material) {
    Point point;
    point.offset = p_offset;
    point.material = p_material;
    is_sorted = false;
    points.push_back(point);
    emit_changed();
}

void GradientGaeaMaterial::remove_point(int p_index) {
    ERR_FAIL_UNSIGNED_INDEX((uint32_t) p_index, points.size());
    ERR_FAIL_COND(points.size() < 1);
    points.remove_at(p_index);
    emit_changed();
}

void GradientGaeaMaterial::set_offset(int pos, const float offset) {
    ERR_FAIL_UNSIGNED_INDEX((uint32_t) pos, points.size());
    _update_sorting();
    points[pos].offset = offset;
    is_sorted = false;
    emit_changed();
}

float GradientGaeaMaterial::get_offset(int pos) {
    ERR_FAIL_UNSIGNED_INDEX_V((uint32_t) pos, points.size(), 0.0);
    _update_sorting();
    return points[pos].offset;
}

void GradientGaeaMaterial::set_material(int pos, const Ref<GaeaMaterial>& material) {
    ERR_FAIL_UNSIGNED_INDEX((uint32_t) pos, points.size());
    _update_sorting();
    points[pos].material = material;
    emit_changed();
}

Ref<GaeaMaterial> GradientGaeaMaterial::get_material(int pos) {
    ERR_FAIL_UNSIGNED_INDEX_V((uint32_t) pos, points.size(), nullptr);
    _update_sorting();
    return points[pos].material;
}

int GradientGaeaMaterial::get_point_count() const {
    return points.size();
}

Ref<GaeaMaterial> GradientGaeaMaterial::get_sampled_resource(const Ref<RandomNumberGenerator>& p_rng, const real_t value) {
    return get_material_at_offset(value);
}

GradientGaeaMaterial::GradientGaeaMaterial() {
    points.resize(2);
    points[0].offset = 0.0;
    points[1].offset = 0.5;
}
