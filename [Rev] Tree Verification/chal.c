#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ISLAB_RAND_MAX 32767
unsigned int gSeed = 0;

int verificationCounter = 0;
unsigned long long verificationHashes[34] = {
    0xcd3730bc64dbae54,
    0x8843e205e477e80c,
    0x70657b2e52e45b37,
    0x15eb3703c3c4c62c,
    0xb3ae6a25e2ba38ae,
    0xf49f6a04285da8a5,
    0x897636c9138c6adf,
    0x3610a5b51a0ee1cd,
    0x781bb6df68433b30,
    0xfb3fe8308bb56491,
    0xac29303ce3d7830c,
    0x44b87beea9dff4b5,
    0xdd90b918def372ef,
    0x1d1b36189d966780,
    0xe25a7f1d3f28d5f1,
    0x31f228baa2369c4f,
    0xb97f7b54fdc140fa,
    0x8cfa29a360af1232,
    0x9cec13d0148c9fa6,
    0x8596b5ab713b7c3a,
    0x6fab1feb85f9dbcf,
    0x9c66481836abeae1,
    0xac6d2ab0f58502f4,
    0x4ab1082c61d4ca82,
    0x34ced681f1eaff11,
    0x4e22b66e244af793,
    0xde04635c44f21b86,
    0x636fd3b27f4338b3,
    0x7c9771ec68f41341,
    0x1bb561eb066414fa,
    0x9dd67092747e17f5,
    0xbbfe94bf9bff2821,
    0x168ed35ee96700a,
    0xc9397980bc130599
};

void SetRandSeed(unsigned int seed) {
    gSeed = seed;
}

int GetRand(void) {
    gSeed = gSeed * 214013 + 2531011;
    return (gSeed >> 16) & 0x7FFF;
}

typedef struct Node {
    char val;
    int id;
    char name[10];
    char *dummy1;
    double dummy2;
    unsigned long dummy3;
    void (*dummy4)(int, char*);
    struct Node *left;
    struct Node *right;
} Node;

char* GenerateString(int seed) {
    const int STRING_LENGTH = 16;
    const char charset[] = "abcdefghijklmnopqrstuvwxyz"
                           "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                           "0123456789";
    const int charset_size = (int)(sizeof(charset) - 1);

    char* result_string = (char*)malloc(STRING_LENGTH + 1);
    if (result_string == NULL) {
        return NULL;
    }

    SetRandSeed(seed);
    for (int i = 0; i < STRING_LENGTH; i++) {
        int key = GetRand() % charset_size;
        result_string[i] = charset[key];
    }

    result_string[STRING_LENGTH] = '\0';
    return result_string;
}

double GenerateDouble(int seed) {
    SetRandSeed(seed);
    return (double)GetRand() / ((double)ISLAB_RAND_MAX + 1.0);
}

void NodeFun(int master_key, char* session_id) {
    long long temporary_calculation_seed = 0x1234ABCD;
    unsigned int permission_bitmask = (unsigned int)(master_key * 131);
    permission_bitmask = (permission_bitmask << (master_key % 5)) ^ (permission_bitmask >> 3);

    char local_alignment_buffer[128];
    void* memory_block_pointer = &local_alignment_buffer;

    memset(memory_block_pointer, permission_bitmask & 0xFF, 128);
    long long checksum_result = llabs(temporary_calculation_seed - master_key);
    size_t session_length = strlen(session_id);
    for (int i = 0; i < (int)session_length; ++i) {
        checksum_result = (checksum_result * 41) % 0xABCD1234;
    }

    return;
}

unsigned long long CalculateHash(
    char val,
    int id,
    char name[10],
    char *dummy1,
    double dummy2,
    unsigned long dummy3)
{
    unsigned long long hash = 0xcbf29ce484222325ULL;
    const unsigned long long FNV_PRIME = 0x100000001b3ULL;

    hash = (hash ^ (unsigned char)val) * FNV_PRIME;
    hash = (hash ^ (unsigned int)id) * FNV_PRIME;
    for (int i = 0; i < strlen(name); ++i) {
        hash = (hash ^ (unsigned char)name[i]) * FNV_PRIME;
    }

    if (dummy1 != NULL) {
        for (const char* p = dummy1; *p; p++) {
            hash = (hash ^ (unsigned char)*p) * FNV_PRIME;
        }
    }
    
    unsigned char* t = (unsigned char*)&dummy2;
    for (int i = 0; i < sizeof(double); i++) {
        hash = (hash ^ t[i]) * FNV_PRIME;
    }

    hash = (hash ^ dummy3) * FNV_PRIME;
    hash ^= hash >> 33;
    hash *= 0xff51afd7ed558ccdULL;
    hash ^= hash >> 33;
    hash *= 0xc4ceb9fe1a85ec53ULL;
    hash ^= hash >> 33;
    return hash;
}

Node* CreateNode(char val, Node* left, Node* right) {
    Node* node = (Node*)malloc(sizeof(Node));
    if (node == NULL) {
        exit(1);
    }

    node->val = val;
    node->id = GetRand();
    strcpy(node->name, "is1abCTF");
    node->dummy1 = GenerateString(node->id);
    node->dummy2 = (double)GetRand() / ((double)ISLAB_RAND_MAX + 1.0);
    node->dummy3 = 0xDEADBEEF + node->id;
    node->dummy4 = NodeFun;
    node->left = left;
    node->right = right;
    return node;
}

Node* BuildTree() {
    Node *node15 = CreateNode('R', NULL, NULL);
    Node *node16 = CreateNode('A', node15, NULL);
    Node *node17 = CreateNode('v', node16, NULL);
    Node *node14 = CreateNode('t', NULL, NULL);
    Node *node18 = CreateNode('3', node14, node17);
    Node *node19 = CreateNode('R', node18, NULL);
    Node *node13 = CreateNode('_', NULL, NULL);
    Node *node20 = CreateNode('$', node13, node19);
    Node *node25 = CreateNode('S', NULL, NULL);
    Node *node24 = CreateNode('1', NULL, NULL);
    Node *node26 = CreateNode('_', node24, node25);
    Node *node22 = CreateNode('1', NULL, NULL);
    Node *node23 = CreateNode('_', node22, NULL);
    Node *node27 = CreateNode('$', node23, node26);
    Node *node28 = CreateNode('0', node27, NULL);
    Node *node29 = CreateNode('_', NULL, NULL);
    Node *node30 = CreateNode('F', node29, NULL);
    Node *node31 = CreateNode('U', node28, node30);
    Node *node6 = CreateNode('T', NULL, NULL);
    Node *node7 = CreateNode('F', node6, NULL);
    Node *node8 = CreateNode('{', node7, NULL);
    Node *node32 = CreateNode('n', NULL, node31);
    Node *node9 = CreateNode('7', NULL, node8);
    Node *node10 = CreateNode('r', NULL, node9);
    Node *node2 = CreateNode('1', NULL, NULL);
    Node *node1 = CreateNode('s', NULL, NULL);
    Node *node3 = CreateNode('a', node1, node2);
    Node *node0 = CreateNode('i', NULL, NULL);
    Node *node4 = CreateNode('b', node0, node3);
    Node *node5 = CreateNode('C', NULL, node4);
    Node *node11 = CreateNode('3', node10, NULL);
    Node *node12 = CreateNode('E', node5, node11);
    Node *node21 = CreateNode('a', node12, node20);
    Node *node33 = CreateNode('}', node21, node32);
    return node33;
}

int VerifyToken(unsigned long long hash) {
    return verificationCounter < 34 && hash == verificationHashes[verificationCounter++];
}

int PostorderVerify(Node* root) {
    if (root == NULL) {
        return 0;
    }

    Node* stack1[100];
    Node* stack2[100];
    int s1_top = -1;
    int s2_top = -1;

    stack1[++s1_top] = root;
    while (s1_top != -1) {
        Node* node = stack1[s1_top--];
        stack2[++s2_top] = node;
        if (node->left) {
            stack1[++s1_top] = node->left;
        }
        if (node->right) {
            stack1[++s1_top] = node->right;
        }
    }

    while (s2_top != -1) {
        Node* node = stack2[s2_top--];
        unsigned long long hash = CalculateHash(
            node->val,
            node->id,
            node->name,
            node->dummy1,
            node->dummy2,
            node->dummy3);
        if (verificationCounter >= 34 || hash != verificationHashes[verificationCounter++]) {
            return 0;
        }
    }

    return 1;
}

void FreeTree(Node* root) {
    if (root == NULL) return;
    FreeTree(root->left);
    FreeTree(root->right);
    free(root);
}

int main() {
    SetRandSeed(0xDEADBEEF);
    Node* root = BuildTree();

    verificationCounter = 0;
    if (PostorderVerify(root)) {
        printf("Verification succeeded!\n");
    }
    else {
        printf("Verification failed!\n");
    }

    FreeTree(root);
    return 0;
}
