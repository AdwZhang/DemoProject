using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InitScroll : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GameObject ob = GameObject.Find("Scroll View");
        InfiniteScroll infiniteScroll = ob.GetComponent<InfiniteScroll>();
        infiniteScroll.SetTotalCount(1000);
        infiniteScroll.Init();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
