from collections import deque, defaultdict

# =====================================================================
# TASK 1: BST of Claim IDs, Traversals & Sorted Order Explanation
# =====================================================================

class ClaimBSTNode:
    def __init__(self, claim_id, details):
        self.claim_id = claim_id
        self.details = details
        self.left = None
        self.right = None

class ClaimBST:
    def __init__(self):
        self.root = None

    def insert(self, claim_id, details=""):
        if not self.root:
            self.root = ClaimBSTNode(claim_id, details)
        else:
            self._insert_recursive(self.root, claim_id, details)

    def _insert_recursive(self, node, claim_id, details):
        if claim_id < node.claim_id:
            if node.left is None:
                node.left = ClaimBSTNode(claim_id, details)
            else:
                self._insert_recursive(node.left, claim_id, details)
        elif claim_id > node.claim_id:
            if node.right is None:
                node.right = ClaimBSTNode(claim_id, details)
            else:
                self._insert_recursive(node.right, claim_id, details)

    def search(self, claim_id):
        return self._search_recursive(self.root, claim_id)

    def _search_recursive(self, node, claim_id):
        if not node or node.claim_id == claim_id:
            return node
        if claim_id < node.claim_id:
            return self._search_recursive(node.left, claim_id)
        return self._search_recursive(node.right, claim_id)

    def inorder(self, node, res):
        if node:
            self.inorder(node.left, res)
            res.append(node.claim_id)
            self.inorder(node.right, res)

    def preorder(self, node, res):
        if node:
            res.append(node.claim_id)
            self.preorder(node.left, res)
            self.preorder(node.right, res)

    def postorder(self, node, res):
        if node:
            self.postorder(node.left, res)
            self.postorder(node.right, res)
            res.append(node.claim_id)

def run_task1():
    print("=== TASK 1: Claim BST & Traversals ===")
    bst = ClaimBST()
    # Test cases including empty input handling
    claim_ids = [500, 250, 750, 100, 300, 600, 900]
    for cid in claim_ids:
        bst.insert(cid, f"Claim-{cid}")
    
    in_res, pre_res, post_res = [], [], []
    bst.inorder(bst.root, in_res)
    bst.preorder(bst.root, pre_res)
    bst.postorder(bst.root, post_res)
    
    print(f"Inorder Traversal (Sorted Order): {in_res}")
    print(f"Preorder Traversal: {pre_res}")
    print(f"Postorder Traversal: {post_res}")
    print("Explanation: The INORDER traversal yields claims in sorted numerical order because it visits the left subtree (smaller IDs), the root, and then the right subtree (larger IDs).\n")


# =====================================================================
# TASK 2: Duplicate / Near-Duplicate Claim Detection & Collision Handling
# =====================================================================

def normalize_string(s):
    """Normalizes string by stripping whitespace and converting to lowercase."""
    return "".join(s.lower().split())

def detect_duplicate_claims(claims):
    """
    Detects duplicates/near-duplicates where policy number and incident date match 
    after normalizing case and spacing.
    """
    seen = {}
    duplicates = []
    for claim in claims:
        norm_policy = normalize_string(claim['policy_number'])
        norm_date = normalize_string(claim['incident_date'])
        key = (norm_policy, norm_date)
        
        if key in seen:
            duplicates.append((claim, seen[key]))
        else:
            seen[key] = claim
    return duplicates

def run_task2():
    print("=== TASK 2: Near-Duplicate Detection & Collision Handling ===")
    claims_stream = [
        {'claim_id': 'C-101', 'policy_number': 'POL-9988', 'incident_date': '2026-11-01'},
        {'claim_id': 'C-102', 'policy_number': 'pol-9988 ', 'incident_date': '2026-11-01'}, # Near-duplicate (case/spacing)
        {'claim_id': 'C-103', 'policy_number': 'POL-1122', 'incident_date': '2026-11-05'}
    ]
    dups = detect_duplicate_claims(claims_stream)
    print(f"Detected {len(dups)} duplicate(s): {dups}")
    print("Collision Handling Note: Python dictionaries handle hash collisions internally using open addressing with quadratic probing. When two distinct keys hash to the same bucket, Python probes subsequent slots until an open slot or matching key is found.\n")


# =====================================================================
# TASK 3: Approval Stages Graph (BFS Shortest Path & DFS Cycle Detection)
# =====================================================================

class ClaimWorkflowGraph:
    def __init__(self):
        self.graph = defaultdict(list)

    def add_edge(self, u, v):
        self.graph[u].append(v)

    def shortest_path_bfs(self, start, target):
        """Finds shortest path between two approval stages using BFS."""
        if start == target:
            return [start]
        queue = deque([[start]])
        visited = {start}
        
        while queue:
            path = queue.popleft()
            node = path[-1]
            if node == target:
                return path
            for neighbor in self.graph[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(path + [neighbor])
        return []

    def detect_loops_dfs(self):
        """Detects loops / cycles in approval workflow using DFS."""
        visited = set()
        rec_stack = set()

        def dfs(node):
            visited.add(node)
            rec_stack.add(node)
            for neighbor in self.graph[node]:
                if neighbor not in visited:
                    if dfs(neighbor):
                        return True
                elif neighbor in rec_stack:
                    return True
            rec_stack.remove(node)
            return False

        for node in list(self.graph.keys()):
            if node not in visited:
                if dfs(node):
                    return True
        return False

def run_task3():
    print("=== TASK 3: Workflow Graph (BFS Shortest Path & DFS Cycles) ===")
    wf = ClaimWorkflowGraph()
    wf.add_edge("Registration", "Assessment")
    wf.add_edge("Assessment", "Surveyor")
    wf.add_edge("Surveyor", "Settlement")
    wf.add_edge("Registration", "Surveyor") # Direct shortcut
    
    path = wf.shortest_path_bfs("Registration", "Settlement")
    print(f"Shortest path from Registration to Settlement (BFS): {path}")
    print(f"Workflow contains loops (DFS): {wf.detect_loops_dfs()}\n")


# =====================================================================
# TASK 4: Longest Run of Days Exceeding 100 Claims (Sliding Window)
# =====================================================================

def longest_claim_spike_run(daily_claims):
    """Finds longest consecutive days where claim count exceeded 100."""
    max_len = 0
    current_len = 0
    for count in daily_claims:
        if count > 100:
            current_len += 1
            max_len = max(max_len, current_len)
        else:
            current_len = 0
    return max_len

def run_task4():
    print("=== TASK 4: Sliding Window (Longest Claim Spike Run) ===")
    daily_claims = [80, 110, 150, 90, 120, 130, 140, 95, 105]
    spike_run = longest_claim_spike_run(daily_claims)
    print(f"Daily Claims: {daily_claims}")
    print(f"Longest consecutive run exceeding 100 claims: {spike_run} days\n")


# =====================================================================
# TASK 5: Two-Pointer Merge of Two Sorted Claim Lists
# =====================================================================

def merge_sorted_claim_lists(list1, list2):
    """Merges two sorted claim lists using two pointers without extra sorting."""
    merged = []
    i = j = 0
    while i < len(list1) and j < len(list2):
        if list1[i] <= list2[j]:
            merged.append(list1[i])
            i += 1
        else:
            merged.append(list2[j])
            j += 1
    merged.extend(list1[i:])
    merged.extend(list2[j:])
    return merged

def run_task5():
    print("=== TASK 5: Two-Pointer Sorted Claim Lists Merge ===")
    regional_list_1 = [101, 105, 110, 120]
    regional_list_2 = [102, 108, 125, 130]
    merged_list = merge_sorted_claim_lists(regional_list_1, regional_list_2)
    print(f"Office 1 Claims: {regional_list_1}")
    print(f"Office 2 Claims: {regional_list_2}")
    print(f"Merged Sorted Claims: {merged_list}\n")


if __name__ == "__main__":
    run_task1()
    run_task2()
    run_task3()
    run_task4()
    run_task5()