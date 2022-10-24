#[compute]

#version 450

// Based on this tweet by Clay John:
// https://twitter.com/john_clayjohn/status/1306447928932753408

layout(local_size_x = 4) in;

layout(set = 0, binding = 0, std430) restrict buffer MyBuffer {
  double data[];
}
my_buffer;

void main() {
    // gl_GlobalInvocationID.x uniquely identifies this invocation within the work group
    my_buffer.data[gl_GlobalInvocationID.x] *= 2.0;