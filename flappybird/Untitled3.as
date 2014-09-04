package
{
	// import quick box2d
	import com.actionsnippet.qbox.*;

    // other stuff
    import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;


    public class PhysicsData extends Object
	{
		// ptm ratio
        public var ptm_ratio:Number = 32;
		
		// the physcis data 
		var dict:Dictionary;
		
        public function createBody(name:String, sim:QuickBox2D, xPos:Number, yPos:Number):QuickObject
        {
			var fixture:Array = dict[name][0];

           	return sim.addPoly({
                        x:xPos, y:yPos, 
                        density:fixture[0], 
                        friction:fixture[1], 
                        restitution:fixture[2],
                        categoryBits: fixture[3],
                        maskBits:fixture[4],
                        groupIndex: fixture[5],
                        verts:fixture[8],
						skin:getDefinitionByName(name)
                        });							
			}
		
        public function PhysicsData(): void
		{
			dict = new Dictionary();
			

			dict["Flappy_Bruin_Right"] = [

										[
											// density, friction, restitution
                                            2, 0, 0,
                                            // categoryBits, maskBits, groupIndex, isSensor
											1, 65535, 0, false,
											'POLYGON',
											[

                                                [   3.5/ptm_ratio, 2/ptm_ratio  ,  7/ptm_ratio, 1.5/ptm_ratio  ,  5.5/ptm_ratio, 6/ptm_ratio  ,  3/ptm_ratio, 6.5/ptm_ratio  ] ,
                                                [   51.5/ptm_ratio, 12/ptm_ratio  ,  42.5/ptm_ratio, 23/ptm_ratio  ,  46/ptm_ratio, 4.5/ptm_ratio  ,  51/ptm_ratio, 5.5/ptm_ratio  ] ,
                                                [   12/ptm_ratio, 11.5/ptm_ratio  ,  8/ptm_ratio, 17.5/ptm_ratio  ,  2/ptm_ratio, 17.5/ptm_ratio  ,  1.5/ptm_ratio, 16/ptm_ratio  ,  6.5/ptm_ratio, 11/ptm_ratio  ] ,
                                                [   59.5/ptm_ratio, 30/ptm_ratio  ,  59.5/ptm_ratio, 32/ptm_ratio  ,  56/ptm_ratio, 34.5/ptm_ratio  ,  35/ptm_ratio, 33.5/ptm_ratio  ,  27/ptm_ratio, 30.5/ptm_ratio  ,  46/ptm_ratio, 25.5/ptm_ratio  ,  56/ptm_ratio, 25.5/ptm_ratio  ] ,
                                                [   46/ptm_ratio, 4.5/ptm_ratio  ,  42.5/ptm_ratio, 23/ptm_ratio  ,  27/ptm_ratio, 5.5/ptm_ratio  ,  28.5/ptm_ratio, 3/ptm_ratio  ,  37/ptm_ratio, 0.5/ptm_ratio  ,  42/ptm_ratio, 0.5/ptm_ratio  ] ,
                                                [   14.5/ptm_ratio, 20/ptm_ratio  ,  12/ptm_ratio, 11.5/ptm_ratio  ,  42.5/ptm_ratio, 23/ptm_ratio  ,  46/ptm_ratio, 25.5/ptm_ratio  ,  27/ptm_ratio, 30.5/ptm_ratio  ] ,
                                                [   12/ptm_ratio, 11.5/ptm_ratio  ,  14.5/ptm_ratio, 20/ptm_ratio  ,  8/ptm_ratio, 17.5/ptm_ratio  ] ,
                                                [   27/ptm_ratio, 5.5/ptm_ratio  ,  12.5/ptm_ratio, 10/ptm_ratio  ,  6/ptm_ratio, 7.5/ptm_ratio  ,  5.5/ptm_ratio, 6/ptm_ratio  ,  7/ptm_ratio, 1.5/ptm_ratio  ] ,
                                                [   27/ptm_ratio, 5.5/ptm_ratio  ,  42.5/ptm_ratio, 23/ptm_ratio  ,  12/ptm_ratio, 11.5/ptm_ratio  ,  12.5/ptm_ratio, 10/ptm_ratio  ]
											]
										]

									];

		}
	}
}
