def remove_duplicates(s):
    seen = []
    result = ""
    for char in s:
        if char not in seen:
            seen.append(char)
            result += char
    return result
string = input()
print(remove_duplicates(string))
