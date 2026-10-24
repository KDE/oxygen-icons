import os
import subprocess

git_root = "/home/nuno/media/server/svnserver/Oxygen6/oxygen-icons"
base_dir = os.path.join(git_root, "simbolicActions")
sizes = ["16x16", "22x22", "24x24", "32x32", "48x48"]

for size in sizes:
    dir_path = os.path.join(base_dir, f"{size}/actions")
    if not os.path.exists(dir_path):
        continue
        
    svg_files = []
    for f in os.listdir(dir_path):
        if f.endswith('.svg'):
            path = os.path.join(dir_path, f)
            if not os.path.islink(path):
                svg_files.append(path)
                
    print(f"Optimizing {len(svg_files)} files in {size}/actions with Inkscape...")
    for filepath in svg_files:
        try:
            cmd = ["inkscape", "--vacuum-defs", "--export-plain-svg", "--export-filename=" + filepath, "--export-overwrite", filepath]
            subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        except Exception as e:
            print(f"Error optimizing {filepath}: {e}")
            
    # Stage and commit per size from git root
    rel_dir = f"simbolicActions/{size}/actions"
    subprocess.run(["git", "add", rel_dir], cwd=git_root, check=True)
    
    status = subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=git_root)
    if status.returncode != 0:
        commit_msg = f"optimize SVG icons in {size} with Inkscape --vacuum-defs --export-plain-svg"
        subprocess.run(["git", "commit", "-m", commit_msg], cwd=git_root, check=True)
        print(f"Committed changes for {size}")
    else:
        print(f"No changes to commit for {size}")

print("Per-size optimization and commits completed.")
