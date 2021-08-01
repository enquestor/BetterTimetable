type Department = {
    name: {
        [key: string]: string
    }
    id: string
    grades: Array<{
        name: {
            [key: string]: string
        }
        value: string
    }>
}

export default Department