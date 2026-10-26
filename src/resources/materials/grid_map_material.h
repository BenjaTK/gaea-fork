#pragma once

#include "material.h"

#include <godot_cpp/classes/resource.hpp>

namespace godot {
    class GridMapGaeaMaterial : public GaeaMaterial {
        GDCLASS(GridMapGaeaMaterial, GaeaMaterial)

    private:
        int item_idx;
        int orientation;

    protected:
        static void _bind_methods();

    public:
        void set_item_idx(const int value);
        int get_item_idx() const;

        void set_orientation(const int value);
        int get_orientation() const;

        virtual bool is_sampled() const override { return false; }

        virtual bool is_data() const override { return true; }

        GridMapGaeaMaterial() {
            item_idx = 0;
            orientation = 0;
        }
    };
}// namespace godot
