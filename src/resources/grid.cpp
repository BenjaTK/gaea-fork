#include "grid.h"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GaeaSample::_bind_methods() {
    GaeaGridTemplate<GaeaSample, real_t>::_bind_methods();
}

void GaeaMap::_bind_methods() {
    GaeaGridTemplate<GaeaMap, Ref<Resource>>::_bind_methods();
}
