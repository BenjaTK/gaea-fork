#pragma once

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/texture2d.hpp>

namespace godot {

class GaeaGeneratorGD : public Node {
	GDCLASS(GaeaGeneratorGD, Node)

	Ref<Texture2D> texture;

private:
	double time_passed;

protected:
	static void _bind_methods();

public:
	GaeaGeneratorGD();
	~GaeaGeneratorGD();

	void _process(double delta) override;
};

} // namespace godot
