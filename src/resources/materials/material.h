#pragma once

#include "godot_cpp/classes/random_number_generator.hpp"
#include "godot_cpp/classes/wrapped.hpp"

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/gdvirtual.gen.inc>

namespace godot {
    class GaeaMaterial : public Resource {
        GDCLASS(GaeaMaterial, Resource)

    private:
        Color preview_color;

    protected:
        static void _bind_methods();

        GDVIRTUAL0RC_REQUIRED(bool, _is_sampled);
        GDVIRTUAL0RC_REQUIRED(bool, _is_data);
        GDVIRTUAL2RC(Ref<GaeaMaterial>, _get_sampled_resource, Ref<RandomNumberGenerator>, real_t);
        GDVIRTUAL1RC(Ref<GaeaMaterial>, _get_resource, Ref<RandomNumberGenerator>);

    public:
        enum {
            RECURSIVE_LIMIT = 10
        };

        GaeaMaterial();

        void set_preview_color(const Color value);
        Color get_preview_color() const;

        virtual bool is_sampled() const;
        virtual bool is_data() const;

        virtual Ref<GaeaMaterial> get_sampled_resource(const Ref<RandomNumberGenerator>& p_rng, const real_t value);

        virtual Ref<GaeaMaterial> get_resource(const Ref<RandomNumberGenerator>& p_rng);

        Ref<GaeaMaterial> prepare_sample(const Ref<RandomNumberGenerator>& p_rng);
        Ref<GaeaMaterial> execute_sample(const Ref<RandomNumberGenerator>& p_rng, const real_t value);
    };
}// namespace godot
