#pragma once

#include "materials/material.h"

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/variant/variant.hpp>

namespace godot {
    class GaeaGrid : public RefCounted {
        GDCLASS(GaeaGrid, RefCounted);

    protected:
        static void _bind_methods() {}

    public:
        GaeaGrid() = default;
    };

    template<class Derived, typename V>
    class GaeaGridTemplate : public GaeaGrid {
    protected:
        static void _bind_methods();
        AHashMap<Vector3i, V> grid;
        Vector3i size;
        Vector3i position;
        Vector3i end;

    public:
        Vector3i get_size() const;
        Vector3i get_position() const;
        Vector3i get_end() const;

        void set_cell(const Vector3i cell, const V p_variant);
        void set_xyz(const int32_t x, const int32_t y, const int32_t z, const V p_variant);
        V get_cell(const Vector3i cell, const V default_value) const;
        V get_xyz(const int32_t x, const int32_t y, const int32_t z, const V default_value) const;
        TypedArray<Vector3i> get_cells() const;
        int32_t get_cell_count() const;
        bool has(const Vector3i cell) const;
        void erase(const Vector3i cell);
        bool is_empty() const;
        void fill(const AABB& area, const V p_variant);
        void clear();

        static const StringName& get_class_static();

        GaeaGridTemplate();

        ~GaeaGridTemplate() { clear(); }
    };

    class GaeaSample : public GaeaGridTemplate<GaeaSample, real_t> {
        GDCLASS(GaeaSample, GaeaGrid)

    protected:
        static void _bind_methods();

    public:
        static real_t get_default_value() { return NAN; }
    };

    class GaeaMap : public GaeaGridTemplate<GaeaMap, Ref<GaeaMaterial>> {
        GDCLASS(GaeaMap, GaeaGrid)

    protected:
        static void _bind_methods();

    public:
        static Ref<GaeaMaterial> get_default_value() { return Variant(); }
    };

    template<class Derived, typename V>
    void GaeaGridTemplate<Derived, V>::_bind_methods() {
        ClassDB::bind_method(D_METHOD("set_cell", "cell", "value"), &Derived::set_cell);
        ClassDB::bind_method(D_METHOD("set_xyz", "x", "y", "z", "value"), &Derived::set_xyz);
        ClassDB::bind_method(D_METHOD("get_cell", "cell", "default_value"), &Derived::get_cell, DEFVAL(Derived::get_default_value()));
        ClassDB::bind_method(D_METHOD("get_xyz", "x", "y", "z", "default_value"), &Derived::get_xyz, DEFVAL(Derived::get_default_value()));
        ClassDB::bind_method(D_METHOD("get_cells"), &Derived::get_cells);
        ClassDB::bind_method(D_METHOD("get_cell_count"), &Derived::get_cell_count);
        ClassDB::bind_method(D_METHOD("has", "cell"), &Derived::has);
        ClassDB::bind_method(D_METHOD("erase", "cell"), &Derived::erase);
        ClassDB::bind_method(D_METHOD("is_empty"), &Derived::is_empty);
        ClassDB::bind_method(D_METHOD("fill", "area", "value"), &Derived::fill);
        ClassDB::bind_method(D_METHOD("get_size"), &Derived::get_size);
        ClassDB::bind_method(D_METHOD("get_position"), &Derived::get_position);
        ClassDB::bind_method(D_METHOD("get_end"), &Derived::get_end);

        ADD_PROPERTY(PropertyInfo(Variant::VECTOR3I, "size"), "", "get_size");
        ADD_PROPERTY(PropertyInfo(Variant::VECTOR3I, "position"), "", "get_position");
        ADD_PROPERTY(PropertyInfo(Variant::VECTOR3I, "end"), "", "get_end");
    }

    template<class Derived, typename V>
    Vector3i GaeaGridTemplate<Derived, V>::get_size() const {
        return size;
    }

    template<class Derived, typename V>
    Vector3i GaeaGridTemplate<Derived, V>::get_position() const {
        return position;
    }

    template<class Derived, typename V>
    Vector3i GaeaGridTemplate<Derived, V>::get_end() const {
        return end;
    }

    template<class Derived, typename V>
    void GaeaGridTemplate<Derived, V>::set_cell(const Vector3i cell, const V p_variant) {
        grid[cell] = p_variant;
        position = position.min(cell);
        end = end.max(cell);
        size = end - position + Vector3i(1, 1, 1);
    }

    template<class Derived, typename V>
    void GaeaGridTemplate<Derived, V>::set_xyz(const int32_t x, const int32_t y, const int32_t z, const V p_variant) {
        set_cell(Vector3i(x, y, z), p_variant);
    }

    template<class Derived, typename V>
    V GaeaGridTemplate<Derived, V>::get_cell(const Vector3i cell, const V default_value) const {
        if (!grid.has(cell)) { return default_value; }
        return grid.get(cell);
    }

    template<class Derived, typename V>
    V GaeaGridTemplate<Derived, V>::get_xyz(const int32_t x, const int32_t y, const int32_t z, const V default_value) const {
        return get_cell(Vector3i(x, y, z), default_value);
    }

    template<class Derived, typename V>
    TypedArray<Vector3i> GaeaGridTemplate<Derived, V>::get_cells() const {
        TypedArray<Vector3i> arr;
        if (grid.is_empty()) { return arr; }
        for (auto i = grid.begin(); i != grid.end(); ++i) {
            arr.append(i->key);
        }
        return arr;
    }

    template<class Derived, typename V>
    int GaeaGridTemplate<Derived, V>::get_cell_count() const {
        return grid.size();
    }

    template<class Derived, typename V>
    bool GaeaGridTemplate<Derived, V>::has(const Vector3i cell) const {
        return grid.has(cell);
    }

    template<class Derived, typename V>
    void GaeaGridTemplate<Derived, V>::erase(const Vector3i cell) {
        grid.erase(cell);
    }

    template<class Derived, typename V>
    bool GaeaGridTemplate<Derived, V>::is_empty() const {
        return grid.is_empty();
    }

    template<class Derived, typename V>
    void GaeaGridTemplate<Derived, V>::fill(const AABB& area, const V p_variant) {
        for (int x = area.position.x; x < area.get_end().x; x++) {
            for (int y = area.position.y; y < area.get_end().y; y++) {
                for (int z = area.position.z; z < area.get_end().z; z++) {
                    set_xyz(x, y, z, p_variant);
                }
            }
        }
    }

    template<class Derived, typename V>
    void GaeaGridTemplate<Derived, V>::clear() {
        TypedArray<Vector3i> cells = get_cells();
        for (int i = 0; i < cells.size(); i++) {
            erase(cells[i]);
        }
    }

    template<class Derived, typename V>
    GaeaGridTemplate<Derived, V>::GaeaGridTemplate() : GaeaGrid() {}

    template<class Derived, typename V>
    const StringName& GaeaGridTemplate<Derived, V>::get_class_static() {
        return Derived::get_class_static();
    }

}// namespace godot
