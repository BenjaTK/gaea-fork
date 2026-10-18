#include "generator.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GaeaGeneratorGD::_bind_methods() {
}

GaeaGeneratorGD::GaeaGeneratorGD() {
	// Initialize any variables here.
	time_passed = 0.0;
}

GaeaGeneratorGD::~GaeaGeneratorGD() {
	// Add your cleanup here.
}

void GaeaGeneratorGD::_process(double delta) {
	time_passed += delta;

	print_line(delta);
}
