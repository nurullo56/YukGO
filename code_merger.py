import os

# Natija yoziladigan fayl nomi
OUTPUT_FILE = "all_project_code.txt"

# Skript o'qishi kerak bo'lgan fayl kengaytmalari
ALLOWED_EXTENSIONS = {'.py', '.dart', '.yaml', '.yml', '.env', '.example', 'dockerfile'}

# Skript e'tiborsiz qoldirishi (skip qilishi) kerak bo'lgan papkalar va fayllar
IGNORE_DIRS = {
    '__pycache__', '.git', '.idea', '.vscode', '.dart_tool', 
    'build', 'android', 'ios', 'web', 'windows', 'linux', 'macos'
}
IGNORE_FILES = {
    OUTPUT_FILE, 'pubspec.lock', '.flutter-plugins', 
    '.flutter-plugins-dependencies', '.metadata'
}

def should_process(file_path, file_name):
    # Fayl nomi yoki kengaytmasi ruxsat etilganlar ro'yxatida bormi?
    ext = os.path.splitext(file_name)[1].lower()
    is_allowed_ext = ext in ALLOWED_EXTENSIONS or file_name.lower() in ALLOWED_EXTENSIONS
    
    # Fayl ignore ro'yxatida emasligini tekshirish
    is_not_ignored = file_name not in IGNORE_FILES
    
    return is_allowed_ext and is_not_ignored

def merge_project_code():
    project_root = os.path.dirname(os.path.abspath(__file__))
    
    with open(os.path.join(project_root, OUTPUT_FILE), 'w', encoding='utf-8') as outfile:
        outfile.write(f"=== LOYIHA KODLARI ARCHIVI ===\n")
        outfile.write(f"Boshlang'ich papka: {project_root}\n")
        outfile.write("=" * 40 + "\n\n")
        
        file_count = 0
        
        for root, dirs, files in os.walk(project_root):
            # Ignore qilinadigan papkalarni chetlab o'tish
            dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
            
            for file in files:
                if should_process(root, file):
                    full_path = os.path.join(root, file)
                    # Loyiha ildiziga nisbatan qisqa yo'lni olish (masalan: backend/main.py)
                    relative_path = os.path.relpath(full_path, project_root)
                    
                    try:
                        with open(full_path, 'r', encoding='utf-8') as infile:
                            content = infile.read()
                            
                            # Har bitta fayl uchun chiroyli ajratuvchi sarlavha
                            outfile.write(f"// {'=' * 76}\n")
                            outfile.write(f"// FAYL: {relative_path}\n")
                            outfile.write(f"// {'=' * 76}\n\n")
                            
                            outfile.write(content)
                            outfile.write("\n\n") # Fayllar orasida joy tashlash
                            
                            print(f"Qo'shildi: {relative_path}")
                            file_count += 1
                    except Exception as e:
                        print(f"Xatolik (o'qib bo'lmadi): {relative_path} -> {e}")
                        
        outfile.write(f"\n=== JAMI QO'SHILGAN FAYLLAR SONI: {file_count} ===")
        print(f"\n Muvaffaqiyatli yakunlandi! Jami {file_count} ta fayl '{OUTPUT_FILE}' ga yig'ildi.")

if __name__ == "__main__":
    merge_project_code()