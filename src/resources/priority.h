#pragma once

#include "godot_cpp/variant/aabb.hpp"

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/gdvirtual.gen.inc>

namespace godot {
    class GaeaPriority : public RefCounted {
        GDCLASS(GaeaPriority, RefCounted)

    protected:
        static void _bind_methods();

        GDVIRTUAL0RC_REQUIRED(float, _get_priority_level)

    public:
        virtual float get_priority_level() const;
    };

    class GaeaBasicPriority : public GaeaPriority {
        GDCLASS(GaeaBasicPriority, GaeaPriority)

    private:
        float level;

    protected:
        static void _bind_methods();

    public:
        static Ref<GaeaBasicPriority> create(const float& p_level);

        void set_level(const float& p_level) { level = p_level; }

        float get_level() const { return level; }

        float get_priority_level() const override { return get_level(); }
    };

    class GaeaGenerationPriority : public GaeaPriority {
        GDCLASS(GaeaGenerationPriority, GaeaPriority)

    private:
        Vector3i origin;
        AABB area;

    protected:
        static void _bind_methods();

    public:
        static Ref<GaeaGenerationPriority> create(const Vector3i& p_origin, const AABB& p_area);

        void set_origin(const Vector3i& p_origin);
        Vector3i get_origin() const;

        void set_area(const AABB& p_area);
        AABB get_area() const;

        float get_priority_level() const override;
    };

}// namespace godot
