#include "material.h"

#include "godot_cpp/classes/global_constants.hpp"
#include "godot_cpp/classes/random_number_generator.hpp"
#include "godot_cpp/classes/wrapped.hpp"
#include "godot_cpp/core/object.hpp"

#include <cstdlib>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GaeaMaterial::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_preview_color", "value"), &GaeaMaterial::set_preview_color);
    ClassDB::bind_method(D_METHOD("get_preview_color"), &GaeaMaterial::get_preview_color);

    GDVIRTUAL_BIND(_is_sampled);
    GDVIRTUAL_BIND(_is_data);
    GDVIRTUAL_BIND(_get_sampled_resource, "rng", "value");
    GDVIRTUAL_BIND(_get_resource, "rng");

    ClassDB::bind_method(D_METHOD("is_sampled"), &GaeaMaterial::is_sampled);
    ClassDB::bind_method(D_METHOD("is_data"), &GaeaMaterial::is_data);

    ClassDB::bind_method(D_METHOD("get_sampled_resource", "rng", "value"), &GaeaMaterial::get_sampled_resource);
    ClassDB::bind_method(D_METHOD("get_resource", "rng"), &GaeaMaterial::get_resource);
    ClassDB::bind_method(D_METHOD("prepare_sample", "rng"), &GaeaMaterial::prepare_sample);
    ClassDB::bind_method(D_METHOD("execute_sample", "rng", "value"), &GaeaMaterial::execute_sample);

    ADD_PROPERTY(PropertyInfo(Variant::COLOR, "preview_color", PROPERTY_HINT_COLOR_NO_ALPHA), "set_preview_color", "get_preview_color");

    BIND_CONSTANT(RECURSIVE_LIMIT);
}

GaeaMaterial::GaeaMaterial() {
    preview_color = Color((float) rand() / RAND_MAX, (float) rand() / RAND_MAX, (float) rand() / RAND_MAX);
}

void GaeaMaterial::set_preview_color(const Color value) {
    preview_color = value;
}

Color GaeaMaterial::get_preview_color() const {
    return preview_color;
}

bool GaeaMaterial::is_sampled() const {
    ERR_FAIL_COND_V(!GDVIRTUAL_IS_OVERRIDDEN(_is_sampled), false);
    bool sampled;
    GDVIRTUAL_CALL(_is_sampled, sampled);
    return sampled;
}

bool GaeaMaterial::is_data() const {
    ERR_FAIL_COND_V(!GDVIRTUAL_IS_OVERRIDDEN(_is_data), false);
    bool data;
    GDVIRTUAL_CALL(_is_data, data);
    return data;
}

Ref<GaeaMaterial> GaeaMaterial::get_sampled_resource(const Ref<RandomNumberGenerator>& p_rng, const real_t value) {
    Ref<GaeaMaterial> ret = Ref<GaeaMaterial>(this);
    GDVIRTUAL_CALL(_get_sampled_resource, p_rng, value, ret);
    return ret;
}

Ref<GaeaMaterial> GaeaMaterial::get_resource(const Ref<RandomNumberGenerator>& p_rng) {
    Ref<GaeaMaterial> ret = Ref<GaeaMaterial>(this);
    GDVIRTUAL_CALL(_get_resource, p_rng, ret);
    return ret;
}

Ref<GaeaMaterial> GaeaMaterial::prepare_sample(const Ref<RandomNumberGenerator>& p_rng) {
    int loop_limit = RECURSIVE_LIMIT;
    Ref<GaeaMaterial> material = Ref<GaeaMaterial>(this);
    while (loop_limit > 0 && !material->is_data() && !material->is_sampled()) {
        loop_limit--;
        material = material->get_resource(p_rng);
    }
    ERR_FAIL_COND_V_MSG(loop_limit == 0, nullptr, "Couldn't get GaeaMaterial from prepare_sample.");
    return material;
}

Ref<GaeaMaterial> GaeaMaterial::execute_sample(const Ref<RandomNumberGenerator>& p_rng, const real_t value) {
    int loop_limit = RECURSIVE_LIMIT;
    Ref<GaeaMaterial> material = Ref<GaeaMaterial>(this);
    while (loop_limit > 0) {
        loop_limit--;
        if (material->is_data()) { return material; }
        if (material->is_sampled()) {
            material = material->get_sampled_resource(p_rng, value);
        } else {
            material = material->get_resource(p_rng);
        }
    }
    ERR_FAIL_V_MSG(nullptr, "Couldn't get GaeaMaterial from execute_sample.");
}
