#pragma once

#include "godot_cpp/core/defs.hpp"
#include "godot_cpp/variant/packed_float32_array.hpp"
#include "godot_cpp/variant/typed_array.hpp"
#include "material.h"

#include <godot_cpp/classes/resource.hpp>

namespace godot {
    class GradientGaeaMaterial : public GaeaMaterial {
        GDCLASS(GradientGaeaMaterial, GaeaMaterial)

    public:
        struct Point {
            float offset = 0.0;
            Ref<GaeaMaterial> material;

            bool operator<(const Point& p_point) const { return offset < p_point.offset; }
        };

    private:
        LocalVector<Point> points;
        bool is_sorted = true;

        _FORCE_INLINE_ void _update_sorting() {
            if (!is_sorted) {
                points.sort();
                is_sorted = true;
            }
        }

    protected:
        static void _bind_methods();

    public:
        void add_point(float p_offset, const Ref<GaeaMaterial>& p_material);
        void remove_point(int p_index);

        void set_offset(int pos, const float offset);
        float get_offset(int pos);

        void set_material(int pos, const Ref<GaeaMaterial>& material);
        Ref<GaeaMaterial> get_material(int pos);

        void set_offsets(const PackedFloat32Array& p_offsets);
        PackedFloat32Array get_offsets() const;

        void set_materials(const TypedArray<Ref<GaeaMaterial>>& p_materials);
        TypedArray<Ref<GaeaMaterial>> get_materials() const;

        _FORCE_INLINE_ Ref<GaeaMaterial> get_material_at_offset(float p_offset) {
            if (points.is_empty()) { return nullptr; }

            _update_sorting();

            int low = 0;
            int high = points.size() - 1;
            int middle = 0;

            while (low <= high) {
                middle = (low + high) / 2;
                const Point& point = points[middle];
                if (point.offset > p_offset) {
                    high = middle - 1;
                } else if (point.offset < p_offset) {
                    low = middle + 1;
                } else {
                    return point.material;
                }
            }

            if (points[middle].offset > p_offset) { middle--; }
            if (middle + 1 >= (int) points.size()) { return points[points.size() - 1].material; }
            if (middle < 0) { return nullptr; }
            return points[middle].material;
        }

        int get_point_count() const;

        bool is_sampled() const override { return true; }

        bool is_data() const override { return false; }

        Ref<GaeaMaterial> get_sampled_resource(const Ref<RandomNumberGenerator>& p_rng, const real_t value) override;

        GradientGaeaMaterial();
    };
}// namespace godot
