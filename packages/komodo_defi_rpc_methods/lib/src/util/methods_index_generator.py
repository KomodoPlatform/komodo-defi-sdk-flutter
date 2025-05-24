import os
import re
import sys


def parse_dart_file(file_path):
    with open(file_path, "r") as file:
        content = file.read()

    # Regex to match classes that extend BaseRequest and their constructors
    class_regex = re.compile(r"class\s+(\w+Request)\s+extends\s+BaseRequest")
    constructor_regex = re.compile(r"(\w+Request)\(([^)]*)\)")

    method_data = {}

    # Find the class that extends BaseRequest
    class_match = class_regex.search(content)
    if class_match:
        class_name = class_match.group(1)

        # Find the constructor
        constructor_match = constructor_regex.search(content)
        if constructor_match:
            constructor_params = constructor_match.group(2)

            # Extract the method information
            method_match = re.search(r"method:\s*'([^']*)'", content)
            if method_match:
                method_name = method_match.group(1)
                method_data[class_name] = {
                    "constructorParams": constructor_params,
                    "methodName": method_name,
                }

    return method_data


def generate_dart_code_refined(methods):
    buffer = []
    buffer.append("// Auto-generated RPC methods index")
    buffer.append("abstract class RpcMethods {")

    class_hierarchy = {}

    for class_name, method_info in methods.items():
        method_segments = method_info["methodName"].split("::")
        current_level = class_hierarchy
        for segment in method_segments[:-1]:
            current_level = current_level.setdefault(segment, {})
        current_level[method_segments[-1]] = {
            "className": class_name,
            "constructorParams": method_info["constructorParams"],
        }

    def generate_class_content(buffer, class_name, class_content, level=1):
        indent = "  " * level
        nested_classes = {
            k: v
            for k, v in class_content.items()
            if isinstance(v, dict) and "className" not in v
        }
        methods = {k: v for k, v in class_content.items() if "className" in v}

        buffer.append(f"class _{class_name.capitalize()}Methods {{")
        buffer.append(f"{indent}const _{class_name.capitalize()}Methods();")

        for method_name, method_details in methods.items():
            constructor_params = (
                method_details["constructorParams"].replace("{", "").replace("}", "")
            )
            positional_params = ", ".join(
                [p.split(" ")[-1] for p in constructor_params.split(",") if p.strip()]
            )
            buffer.append(
                f'{indent}{method_details["className"]} {method_name}({constructor_params}) => {method_details["className"]}({positional_params});'
            )

        for nested_class_name, nested_class_content in nested_classes.items():
            buffer.append(
                f"{indent}static const _{nested_class_name.capitalize()}Methods {nested_class_name} = _{nested_class_name.capitalize()}Methods();"
            )
            generate_class_content(
                buffer, nested_class_name, nested_class_content, level + 1
            )

        buffer.append("}")

    for top_level_class_name, top_level_class_content in class_hierarchy.items():
        buffer.append(
            f"  static const _{top_level_class_name.capitalize()}Methods {top_level_class_name} = _{top_level_class_name.capitalize()}Methods();"
        )
        generate_class_content(buffer, top_level_class_name, top_level_class_content)

    buffer.append("}")
    return "\n".join(buffer)


def run_conversion(input_dir, output_dart_file):
    if not os.path.isdir(input_dir):
        print(f"Error: {input_dir} is not a directory.")
        sys.exit(1)

    dart_files = []
    for root, _, files in os.walk(input_dir):
        for file in files:
            if file.endswith(".dart"):
                dart_files.append(os.path.join(root, file))

    if not dart_files:
        print(f"No Dart files found in {input_dir}")
        sys.exit(1)

    parsed_methods = {}
    for dart_file in dart_files:
        method_info = parse_dart_file(dart_file)
        parsed_methods.update(method_info)

    if not parsed_methods:
        print("No methods found extending `BaseRequest`.")
        sys.exit(1)

    dart_code = generate_dart_code_refined(parsed_methods)

    with open(output_dart_file, "w") as file:
        file.write(dart_code)

    print(f"Generated Dart file saved to: {output_dart_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python generate_rpc_methods.py <input_directory> <output_dart_file>"
        )
        sys.exit(1)

    input_dir = sys.argv[1]
    output_dart_file = sys.argv[2]

    run_conversion(input_dir, output_dart_file)
