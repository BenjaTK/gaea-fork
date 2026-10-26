#include "random_material.h"

#include "godot_cpp/classes/global_constants.hpp"
#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/core/error_macros.hpp"
#include "godot_cpp/core/object.hpp"

using namespace godot;

void RandomGaeaMaterial::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_pointwise", "pointwise"), &RandomGaeaMaterial::set_pointwise);
    ClassDB::bind_method(D_METHOD("is_pointwise"), &RandomGaeaMaterial::is_pointwise);

    ClassDB::bind_method(D_METHOD("add_material", "weight", "material"), &RandomGaeaMaterial::add_material);
    ClassDB::bind_method(D_METHOD("remove_at", "index"), &RandomGaeaMaterial::remove_at);

    ClassDB::bind_method(D_METHOD("set_weight", "idx", "weight"), &RandomGaeaMaterial::set_weight);
    ClassDB::bind_method(D_METHOD("get_weight", "idx"), &RandomGaeaMaterial::get_weight);

    ClassDB::bind_method(D_METHOD("set_material", "idx", "material"), &RandomGaeaMaterial::set_material);
    ClassDB::bind_method(D_METHOD("get_material", "idx"), &RandomGaeaMaterial::get_material);

    ClassDB::bind_method(D_METHOD("set_weights", "weights"), &RandomGaeaMaterial::set_weights);
    ClassDB::bind_method(D_METHOD("get_weights"), &RandomGaeaMaterial::get_weights);

    ClassDB::bind_method(D_METHOD("set_materials", "materials"), &RandomGaeaMaterial::set_materials);
    ClassDB::bind_method(D_METHOD("get_materials"), &RandomGaeaMaterial::get_materials);

    ClassDB::bind_method(D_METHOD("get_random_material", "rng"), &RandomGaeaMaterial::get_random_material);

    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "pointwise"), "set_pointwise", "is_pointwise");
    ADD_PROPERTY(PropertyInfo(Variant::PACKED_FLOAT32_ARRAY, "weights"), "set_weights", "get_weights");
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "materials", PROPERTY_HINT_ARRAY_TYPE, "GaeaMaterial"), "set_materials", "get_materials");
}

void RandomGaeaMaterial::set_pointwise(const bool value) {
    pointwise = value;
}

bool RandomGaeaMaterial::is_pointwise() const {
    return pointwise;
}

void RandomGaeaMaterial::add_material(const float weight, const Ref<GaeaMaterial>& p_material) {
    WeightedMaterial weighted;
    weighted.weight = weight;
    weighted.material = p_material;
    weight_sum += weight;
    weighted_materials.push_back(weighted);
}

void RandomGaeaMaterial::remove_at(const int idx) {
    ERR_FAIL_INDEX((uint32_t) idx, weighted_materials.size());
    weight_sum -= weighted_materials[idx].weight;
    weighted_materials.remove_at(idx);
}

void RandomGaeaMaterial::set_weight(const int idx, const float weight) {
    ERR_FAIL_INDEX((uint32_t) idx, weighted_materials.size());
    weight_sum += weight - weighted_materials[idx].weight;
    weighted_materials[idx].weight = weight;
}

float RandomGaeaMaterial::get_weight(const int idx) const {
    ERR_FAIL_INDEX_V((uint32_t) idx, weighted_materials.size(), NAN);
    return weighted_materials[idx].weight;
}

void RandomGaeaMaterial::set_material(const int idx, const Ref<GaeaMaterial>& p_material) {
    ERR_FAIL_INDEX((uint32_t) idx, weighted_materials.size());
    weighted_materials[idx].material = p_material;
}

Ref<GaeaMaterial> RandomGaeaMaterial::get_material(const int idx) const {
    ERR_FAIL_INDEX_V((uint32_t) idx, weighted_materials.size(), nullptr);
    return weighted_materials[idx].material;
}

void RandomGaeaMaterial::set_weights(const PackedFloat32Array& p_weights) {
    weight_sum = 0;
    weighted_materials.resize(p_weights.size());
    for (uint32_t i = 0; i < weighted_materials.size(); i++) {
        weighted_materials[i].weight = p_weights[i];
        weight_sum += p_weights[i];
    }
}

PackedFloat32Array RandomGaeaMaterial::get_weights() const {
    PackedFloat32Array weights;
    weights.resize(weighted_materials.size());
    for (uint32_t i = 0; i < weighted_materials.size(); i++) {
        weights[i] = weighted_materials[i].weight;
    }
    return weights;
}

void RandomGaeaMaterial::set_materials(const TypedArray<Ref<GaeaMaterial>>& p_materials) {
    weight_sum = 0;
    weighted_materials.resize(p_materials.size());
    for (uint32_t i = 0; i < weighted_materials.size(); i++) {
        weighted_materials[i].material = p_materials[i];
        weight_sum += weighted_materials[i].weight;
    }
}

TypedArray<Ref<GaeaMaterial>> RandomGaeaMaterial::get_materials() const {
    TypedArray<Ref<GaeaMaterial>> materials;
    materials.resize(weighted_materials.size());
    for (uint32_t i = 0; i < weighted_materials.size(); i++) {
        materials[i] = weighted_materials[i].material;
    }
    return materials;
}

Ref<GaeaMaterial> RandomGaeaMaterial::get_resource(const Ref<RandomNumberGenerator>& p_rng) {
    return get_random_material(p_rng);
}

Ref<GaeaMaterial> RandomGaeaMaterial::get_sampled_resource(const Ref<RandomNumberGenerator>& p_rng, const real_t value) {
    return get_random_material(p_rng);
}

RandomGaeaMaterial::RandomGaeaMaterial() {
    pointwise = false;
    weighted_materials.resize(1);
    weighted_materials[0].weight = 100.0;
    weight_sum = 100;
}
