#pragma once

#include "godot_cpp/core/defs.hpp"
#include "godot_cpp/variant/packed_float32_array.hpp"
#include "godot_cpp/variant/typed_array.hpp"
#include "material.h"

#include <godot_cpp/classes/resource.hpp>

namespace godot {
    class RandomGaeaMaterial : public GaeaMaterial {
        GDCLASS(RandomGaeaMaterial, GaeaMaterial)

    protected:
        static void _bind_methods();

    public:
        struct WeightedMaterial {
            float weight;
            Ref<GaeaMaterial> material;
        };

    private:
        LocalVector<WeightedMaterial> weighted_materials;
        float weight_sum;
        bool pointwise;

    public:
        void set_pointwise(const bool value);
        bool is_pointwise() const;

        void add_material(const float weight, const Ref<GaeaMaterial>& p_material);
        void remove_at(const int idx);

        void set_weight(const int idx, const float weight);
        float get_weight(const int idx) const;

        void set_material(const int idx, const Ref<GaeaMaterial>& material);
        Ref<GaeaMaterial> get_material(const int idx) const;

        void set_weights(const PackedFloat32Array& p_weights);
        PackedFloat32Array get_weights() const;

        void set_materials(const TypedArray<Ref<GaeaMaterial>>& p_materials);
        TypedArray<Ref<GaeaMaterial>> get_materials() const;

        _FORCE_INLINE_ Ref<GaeaMaterial> get_random_material(const Ref<RandomNumberGenerator>& rng) const {
            ERR_FAIL_COND_V(weighted_materials.size() < 1, nullptr);
            if (weighted_materials.size() == 1) { return weighted_materials[0].material; }
            float r = rng->randf_range(0.0, weight_sum);
            float sum = 0.0;
            for (int idx = 0; idx < weighted_materials.size(); idx++) {
                sum += weighted_materials[idx].weight;
                if (sum >= r) { return weighted_materials[idx].material; }
            }
            ERR_FAIL_V_MSG(nullptr, "Couldn't get random material from GaeaRandomMaterial. This shouldn't happen.");
        }

        bool is_sampled() const override { return pointwise; }

        bool is_data() const override { return false; }

        Ref<GaeaMaterial> get_resource(const Ref<RandomNumberGenerator>& p_rng) override;
        Ref<GaeaMaterial> get_sampled_resource(const Ref<RandomNumberGenerator>& p_rng, const real_t value) override;

        RandomGaeaMaterial();
    };

}// namespace godot
