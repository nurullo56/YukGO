import os

def get_dir_size(path='.'):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            if not os.path.islink(fp):
                try:
                    total_size += os.path.getsize(fp)
                except FileNotFoundError:
                    pass
    return total_size

def check_project_size():
    current_dir = os.getcwd()
    print(f"📊 Joylashgan joy: {current_dir}\n")
    
    # Xatolik bartaraf etildi: f-string uchun triple-quotes ishlatildi
    print(f"""{"Papka / Fayl nomi":<30} | {"O'lchami (MB)":<15}""")
    print("-" * 50)
    
    total_project_size = 0
    
    try:
        items = os.listdir('.')
    except Exception as e:
        print(f"Xatolik: {e}")
        return

    for item in sorted(items):
        # .git, .idea, .dart_tool kabilarni o'tkazib yubormaslik uchun shartni soddalashtirdik
        if item == 'size_checker.py': 
            continue
            
        try:
            if os.path.isdir(item):
                size_bytes = get_dir_size(item)
            else:
                size_bytes = os.path.getsize(item)
                
            size_mb = size_bytes / (1024 * 1024)
            total_project_size += size_bytes
            print(f"{item:<30} | {size_mb:.2f} MB")
        except FileNotFoundError:
            continue
        
    print("-" * 50)
    print(f"🔥 UMUMIY LOYIHA O'LCHAMI: {total_project_size / (1024 * 1024):.2f} MB")

if __name__ == "__main__":
    check_project_size()