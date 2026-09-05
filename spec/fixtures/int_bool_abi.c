typedef int (*uing_int_callback)(void *data);

int uing_abi_round_trip(int value)
{
    return value;
}

int uing_abi_call(uing_int_callback callback, void *data)
{
    return callback(data);
}
