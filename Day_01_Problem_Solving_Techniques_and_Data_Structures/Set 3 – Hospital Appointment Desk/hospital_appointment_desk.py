import time
import random

# =====================================================================
# TASK 1: Linear vs Binary Search over 20,000 Patient Records (1,000 Lookups)
# =====================================================================

def benchmark_searches():
    print("=== TASK 1: Search Benchmarking (20,000 Records, 1,000 Lookups) ===")
    patients = sorted([{'patientId': i, 'name': f"Patient_{i}"} for i in range(1, 20001)], key=lambda x: x['patientId'])
    lookups = [random.randint(1, 20000) for _ in range(1000)]
    
    # Linear Search Benchmark
    start = time.perf_counter()
    for target in lookups:
        for p in patients:
            if p['patientId'] == target:
                break
    lin_time = (time.perf_counter() - start) * 1000
    
    # Binary Search Benchmark
    start = time.perf_counter()
    for target in lookups:
        low, high = 0, len(patients) - 1
        while low <= high:
            mid = (low + high) // 2
            if patients[mid]['patientId'] == target:
                break
            elif patients[mid]['patientId'] < target:
                low = mid + 1
            else:
                high = mid - 1
    bin_time = (time.perf_counter() - start) * 1000
    
    print(f"Linear Search (1,000 lookups): {lin_time:.2f} ms")
    print(f"Binary Search (1,000 lookups): {bin_time:.2f} ms\n")


# =====================================================================
# TASK 2: Selection Sort vs Quick Sort (Urgency & Arrival Time)
# =====================================================================

def selection_sort_appointments(appointments):
    """O(n^2) Selection Sort tracking swaps."""
    arr = appointments.copy()
    swaps = 0
    n = len(arr)
    for i in range(n):
        min_idx = i
        for j in range(i + 1, n):
            # Sort by urgency descending, then arrival time ascending
            if (arr[j]['urgency'] > arr[min_idx]['urgency']) or \
               (arr[j]['urgency'] == arr[min_idx]['urgency'] and arr[j]['arrival'] < arr[min_idx]['arrival']):
                min_idx = j
        if min_idx != i:
            arr[i], arr[min_idx] = arr[min_idx], arr[i]
            swaps += 1
    return arr, swaps

def quick_sort_appointments(arr):
    """O(n log n) Quick Sort by urgency descending, arrival ascending."""
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if (x['urgency'] > pivot['urgency']) or 
            (x['urgency'] == pivot['urgency'] and x['arrival'] < pivot['arrival'])]
    middle = [x for x in arr if x['urgency'] == pivot['urgency'] and x['arrival'] == pivot['arrival']]
    right = [x for x in arr if (x['urgency'] < pivot['urgency']) or 
             (x['urgency'] == pivot['urgency'] and x['arrival'] > pivot['arrival'])]
    return quick_sort_appointments(left) + middle + quick_sort_appointments(right)

def run_task2_sorting():
    print("=== TASK 2: Sorting Appointments (Selection vs Quick Sort) ===")
    sample_appointments = [
        {'id': 1, 'urgency': 1, 'arrival': '09:30'},
        {'id': 2, 'urgency': 3, 'arrival': '09:00'}, # High urgency
        {'id': 3, 'urgency': 2, 'arrival': '09:15'},
        {'id': 4, 'urgency': 3, 'arrival': '09:05'}  # High urgency, later arrival
    ]
    
    start = time.perf_counter()
    _, sel_swaps = selection_sort_appointments(sample_appointments)
    sel_time = (time.perf_counter() - start) * 1000
    
    start = time.perf_counter()
    _ = quick_sort_appointments(sample_appointments)
    quick_time = (time.perf_counter() - start) * 1000
    
    print(f"Selection Sort Swaps: {sel_swaps} | Time: {sel_time:.4f} ms")
    print(f"Quick Sort Time: {quick_time:.4f} ms\n")


# =====================================================================
# TASK 3: Double-Booked Slot Detection Using Hash Set
# =====================================================================

def detect_double_bookings(appointments):
    """Detects double bookings (same patient and slot) using a hash set. O(n) time."""
    seen = set()
    duplicates = []
    for appt in appt_stream:
        key = (appt['patientId'], appt['slot'])
        if key in seen:
            duplicates.append(appt)
        else:
            seen.add(key)
    return duplicates

def run_task3_duplicates():
    print("=== TASK 3: Double-Booking Detection ===")
    global appt_stream
    appt_stream = [
        {'patientId': 101, 'slot': '10:00 AM', 'doctor': 'Dr. Sharma'},
        {'patientId': 102, 'slot': '10:00 AM', 'doctor': 'Dr. Verma'},
        {'patientId': 101, 'slot': '10:00 AM', 'doctor': 'Dr. Sharma'} # Double booked!
    ]
    dups = detect_double_bookings(appt_stream)
    print(f"Flagged {len(dups)} double-booked appointment(s): {dups}\n")


# =====================================================================
# TASK 4: Walk-in Queue & Recent Patients Stack from Scratch
# =====================================================================

class HospitalQueue:
    def __init__(self):
        self.items = []
    def enqueue(self, token):
        self.items.append(token)
    def dequeue(self):
        return self.items.pop(0) if self.items else None

class PatientStack:
    def __init__(self):
        self.items = []
    def push(self, patient):
        self.items.append(patient)
    def pop(self):
        return self.items.pop() if self.items else None

def run_task4_structures():
    print("=== TASK 4: Walk-in Queue & Recent Patients Stack ===")
    token_queue = HospitalQueue()
    token_queue.enqueue("Token #01: Patient A")
    token_queue.enqueue("Token #02: Patient B")
    
    recent_stack = PatientStack()
    recent_stack.push("Viewed Chart: Patient #101")
    recent_stack.push("Viewed Chart: Patient #105")
    
    print("Calling Queue Token:", token_queue.dequeue())
    print("Popping Recent Patient History:", recent_stack.pop(), "\n")


# =====================================================================
# TASK 5: Maximum Appointments (Interval Scheduling / DP vs Greedy)
# =====================================================================

def max_appointments_greedy(appointments):
    """Greedy interval scheduling sorted by end time."""
    # appointments: list of tuples (start, end)
    sorted_appts = sorted(appointments, key=lambda x: x[1])
    count = 0
    last_end = 0
    for start, end in sorted_appts:
        if start >= last_end:
            count += 1
            last_end = end
    return count

def run_task5_scheduling():
    print("=== TASK 5: Maximum Appointments Scheduling ===")
    # Appointments represented as (start_hour, end_hour)
    shift_appointments = [(9, 10), (9.5, 10.5), (10, 11), (11, 12)]
    max_appts = max_appointments_greedy(shift_appointments)
    print(f"Maximum non-overlapping appointments doctor can attend in shift: {max_appts}\n")


if __name__ == "__main__":
    benchmark_searches()
    run_task2_sorting()
    run_task3_duplicates()
    run_task4_structures()
    run_task5_scheduling()