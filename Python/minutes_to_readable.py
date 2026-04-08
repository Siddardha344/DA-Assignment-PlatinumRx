1. Convert minutes to human-readable form
def minutes_to_readable(total_minutes):
    hours = total_minutes // 60
    minutes = total_minutes % 60

    if hours == 0:
        return f"{minutes} minutes"
    elif minutes == 0:
        return f"{hours} hr"
    else:
        return f"{hours} hr {minutes} minutes"

minutes = input()
print(minutes_to_readable(minutes))

