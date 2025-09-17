import argparse
import shutil
import subprocess
from pathlib import Path

def git_copy_and_push(src: str, dst: str, commit_message: str = "workflow update"): 
    src_path = Path(src)
    dst_path = Path(dst)

    # Copy file
    shutil.copy2(src_path, dst_path)

    # Find repo root
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        cwd=dst_path.parent,
        text=True,
        capture_output=True,
        check=True,
    )
    repo_root = Path(result.stdout.strip())
    
    try:
        subprocess.run(["git", "add", str(dst_path.relative_to(repo_root))], cwd=repo_root, check=True)
        subprocess.run(["git", "commit", "-m", commit_message], cwd=repo_root, check=True)
        subprocess.run(["git", "push"], cwd=repo_root, check=True)
        print(f"✅ {src_path} copied to {dst_path} and pushed to repo {repo_root}")
    except subprocess.CalledProcessError as e:
        print("❌ Git command failed:", e)

def main():
    parser = argparse.ArgumentParser(description="Copy a file to a Git repo and push.")
    parser.add_argument("file", help="Path to the source file to copy")
    parser.add_argument("target", help="Target path inside the Git repo")
    parser.add_argument("message", help="Git commit message")
    args = parser.parse_args()

    git_copy_and_push(args.file, args.target, args.message)


if __name__ == "__main__":
    main()