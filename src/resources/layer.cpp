#include "layer.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GaeaLayer::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_enabled"), &GaeaLayer::get_enabled);
	ClassDB::bind_method(D_METHOD("set_enabled", "value"), &GaeaLayer::set_enabled);

	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enabled"), "set_enabled", "get_enabled");
}

GaeaLayer::GaeaLayer() {
	enabled = true;
}

void GaeaLayer::set_enabled(const bool value) {
	if (enabled != value) {
		enabled = value;
		emit_changed();
	}
}

bool GaeaLayer::get_enabled() const {
	return enabled;
}
