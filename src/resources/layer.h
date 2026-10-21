#pragma once

#include <godot_cpp/classes/resource.hpp>

namespace godot {
    class GaeaLayer : public Resource {
        GDCLASS(GaeaLayer, Resource)

    private:
        bool enabled;

    protected:
        static void _bind_methods();

    public:
        GaeaLayer();
        ~GaeaLayer() override = default;

        void set_enabled(const bool value);
        bool get_enabled() const;
    };
}// namespace godot
